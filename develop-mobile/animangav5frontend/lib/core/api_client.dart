import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'config.dart';

/// Error devuelto por la API con un mensaje legible.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

/// Fichero listo para enviarse en una petición multipart (funciona también en web).
class UploadFile {
  UploadFile({required this.bytes, required this.filename});

  final List<int> bytes;
  final String filename;
}

/// Tokens de la sesión actual.
class Session {
  const Session(this.accessToken, this.refreshToken);
  final String accessToken;
  final String refreshToken;
}

/// Cliente HTTP de la API: añade el token, decodifica JSON en UTF-8, traduce errores y,
/// si el token de acceso caduca, renueva la sesión con el refresh token y repite la petición.
class ApiClient {
  ApiClient({http.Client? client}) : _http = client ?? http.Client();

  final http.Client _http;
  Session? session;

  /// Se llama al renovar la sesión (para guardar los nuevos tokens).
  void Function(Session session)? onSessionRefreshed;

  /// Se llama cuando la sesión no se puede renovar.
  void Function()? onSessionExpired;

  Future<Session?>? _refreshing;

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final params = query?.map((k, v) => MapEntry(k, '$v'))?..removeWhere((k, v) => v == 'null' || v.isEmpty);
    return Uri.parse('${AppConfig.apiUrl}$path').replace(queryParameters: params?.isEmpty ?? true ? null : params);
  }

  Map<String, String> _headers({bool json = false}) => {
        'Accept': 'application/json',
        if (json) 'Content-Type': 'application/json',
        if (session != null) 'Authorization': 'Bearer ${session!.accessToken}',
      };

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(path, () => _http.get(_uri(path, query), headers: _headers()));

  Future<dynamic> post(String path, {Object? body}) => _send(
      path,
      () =>
          _http.post(_uri(path), headers: _headers(json: body != null), body: body == null ? null : jsonEncode(body)));

  Future<dynamic> put(String path, {Object? body}) => _send(path,
      () => _http.put(_uri(path), headers: _headers(json: body != null), body: body == null ? null : jsonEncode(body)));

  Future<dynamic> delete(String path) => _send(path, () => _http.delete(_uri(path), headers: _headers()));

  /// Petición multipart con partes JSON (equivalente a `@RequestPart` de Spring) y ficheros.
  Future<dynamic> multipart(
    String method,
    String path, {
    Map<String, Object> jsonParts = const {},
    Map<String, UploadFile> files = const {},
  }) {
    return _send(path, () async {
      final request = http.MultipartRequest(method, _uri(path))..headers.addAll(_headers());
      jsonParts.forEach((name, value) {
        request.files.add(http.MultipartFile.fromString(name, jsonEncode(value),
            contentType: MediaType('application', 'json'), filename: name));
      });
      files.forEach((name, file) {
        request.files.add(http.MultipartFile.fromBytes(name, file.bytes, filename: file.filename));
      });
      return http.Response.fromStream(await _http.send(request));
    });
  }

  Future<dynamic> _send(String path, Future<http.Response> Function() call, {bool retried = false}) async {
    final http.Response response;
    try {
      response = await call();
    } catch (_) {
      throw ApiException('No se puede conectar con el servidor. Comprueba tu conexión.');
    }

    final body = response.bodyBytes.isEmpty ? null : _decode(response);
    if (response.statusCode >= 200 && response.statusCode < 300) return body;

    final isAuthCall = path.startsWith('/auth/');
    if (response.statusCode == 401 && session != null && !isAuthCall && !retried) {
      final renewed = await _refresh();
      if (renewed != null) return _send(path, call, retried: true);
      onSessionExpired?.call();
    }
    throw ApiException(_errorMessage(response.statusCode, body), statusCode: response.statusCode);
  }

  /// Renueva la sesión una sola vez aunque varias peticiones caduquen a la vez.
  Future<Session?> _refresh() {
    return _refreshing ??= () async {
      try {
        final response = await _http.post(_uri('/auth/refresh'),
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
            body: jsonEncode({'refreshToken': session!.refreshToken}));
        if (response.statusCode != 200) return null;
        final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        session = Session(json['accessToken'] as String, json['refreshToken'] as String);
        onSessionRefreshed?.call(session!);
        return session;
      } catch (_) {
        return null;
      } finally {
        _refreshing = null;
      }
    }();
  }

  dynamic _decode(http.Response response) {
    final text = utf8.decode(response.bodyBytes);
    try {
      return jsonDecode(text);
    } catch (_) {
      return text;
    }
  }

  String _errorMessage(int status, dynamic body) {
    if (body is Map && body['message'] is String && (body['message'] as String).isNotEmpty) {
      return body['message'] as String;
    }
    return switch (status) {
      401 => 'Tu sesión ha caducado. Vuelve a iniciar sesión.',
      403 => 'No tienes permisos para realizar esta acción.',
      404 => 'No se ha encontrado el recurso.',
      _ => 'Ha ocurrido un error ($status).',
    };
  }
}

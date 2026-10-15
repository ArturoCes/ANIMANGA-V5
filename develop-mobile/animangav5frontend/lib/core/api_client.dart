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

/// Cliente HTTP mínimo: añade el token, decodifica JSON en UTF-8 y traduce errores.
class ApiClient {
  ApiClient({http.Client? client}) : _http = client ?? http.Client();

  final http.Client _http;
  String? token;

  /// Se invoca cuando el servidor rechaza el token (sesión caducada).
  void Function()? onUnauthorized;

  Uri _uri(String path, [Map<String, dynamic>? query]) =>
      Uri.parse('${AppConfig.apiUrl}$path').replace(queryParameters: query?.map((k, v) => MapEntry(k, '$v')));

  Map<String, String> _headers({bool json = false}) => {
        'Accept': 'application/json',
        if (json) 'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _http.get(_uri(path, query), headers: _headers()));

  Future<dynamic> post(String path, {Object? body}) => _send(() =>
      _http.post(_uri(path), headers: _headers(json: body != null), body: body == null ? null : jsonEncode(body)));

  Future<dynamic> delete(String path) => _send(() => _http.delete(_uri(path), headers: _headers()));

  /// Petición multipart con partes JSON (equivalente a `@RequestPart` de Spring) y ficheros.
  Future<dynamic> multipart(
    String method,
    String path, {
    Map<String, Object> jsonParts = const {},
    Map<String, UploadFile> files = const {},
    Map<String, dynamic>? query,
  }) {
    return _send(() async {
      final request = http.MultipartRequest(method, _uri(path, query))..headers.addAll(_headers());
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

  Future<dynamic> _send(Future<http.Response> Function() call) async {
    final http.Response response;
    try {
      response = await call();
    } catch (_) {
      throw ApiException('No se puede conectar con el servidor. Comprueba tu conexión.');
    }

    final body = response.bodyBytes.isEmpty ? null : _decode(response);
    if (response.statusCode >= 200 && response.statusCode < 300) return body;

    if (response.statusCode == 401 && token != null) onUnauthorized?.call();
    throw ApiException(_errorMessage(response.statusCode, body), statusCode: response.statusCode);
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
    if (body is Map) {
      final sub = body['subErrores'];
      if (sub is List && sub.isNotEmpty) {
        return sub.map((e) => e['mensaje']).whereType<String>().join('. ');
      }
      final message = body['mensaje'] ?? body['message'];
      if (message is String && message.isNotEmpty) {
        if (status == 401) return 'Usuario o contraseña incorrectos';
        return message;
      }
    }
    return switch (status) {
      401 => 'Tu sesión ha caducado. Vuelve a iniciar sesión.',
      403 => 'No tienes permisos para realizar esta acción.',
      404 => 'No se ha encontrado el recurso.',
      _ => 'Ha ocurrido un error ($status).',
    };
  }
}

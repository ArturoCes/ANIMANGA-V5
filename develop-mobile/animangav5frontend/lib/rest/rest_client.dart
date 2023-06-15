import 'dart:convert';
import 'dart:io';

import 'package:animangav4frontend/models/login_error.dart';
import 'package:animangav4frontend/models/manga.dart';
import 'package:animangav4frontend/models/user.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/errors.dart';

class ApiConstants {
  //&static String baseUrl = "http://localhost:8080";
  static String imageBaseUrl = baseUrl + "/download/";
  static String baseUrl = "https://animanga-apirest-daeec61f336b.herokuapp.com";
}

class HeadersApiInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    try {
      data.headers["Content-Type"] = "application/json";
      data.headers["Accept"] = "application/json";
    } catch (e) {
      print(e);
    }
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async =>
      data;
}

@Order(-10)
@singleton
class RestClient {
  RestClient();
  final box = GetStorage();
  //final _httpClient = http.Client();
  final _httpClient =
      InterceptedClient.build(interceptors: [HeadersApiInterceptor()]);

  Future<dynamic> get(String url,
      {required Map<String, String> headers}) async {
    try {
      Uri uri = Uri.parse(ApiConstants.baseUrl + url);

      final response = await _httpClient.get(uri, headers: headers);
      var responseJson = _response(response);
      return responseJson;
    } on SocketException catch (ex) {
      throw FetchDataException('No internet connection: ${ex.message}');
    }
  }

  Future<dynamic> post(String url, dynamic body) async {
    print('body: ' + body.username);

    try {
      Uri uri = Uri.parse(ApiConstants.baseUrl + url);
      print(uri.toString());

      final response = await _httpClient.post(uri, body: jsonEncode(body));
      var responseJson = _response(response);
      return responseJson;
    } on SocketException catch (ex) {
      throw FetchDataException('No internet connection: ${ex.message}');
    }
  }

   Future<dynamic> post2(String url,
      {required Map<String, String> headers}) async {


    try {
      Uri uri = Uri.parse(ApiConstants.baseUrl + url);
      print(uri.toString());

      final response = await _httpClient.post(uri, headers: headers);
      var responseJson = _response(response);
      return responseJson;
    } on SocketException catch (ex) {
      throw FetchDataException('No internet connection: ${ex.message}');
    }
  }

  Future<dynamic> post3(String url,Map<String, String> headers, dynamic body) async {


    try {
      Uri uri = Uri.parse(ApiConstants.baseUrl + url);
      print(uri.toString());

      final response = await _httpClient.post(uri, headers: headers, body: jsonEncode(body));
      var responseJson = _response(response);
      return responseJson;
    } on SocketException catch (ex) {
      throw FetchDataException('No internet connection: ${ex.message}');
    }
  }

  Future<dynamic> multipartRequest(String url, dynamic body) async {
    Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${box.read('token')}'
    };

    Uri uri = Uri.parse(ApiConstants.baseUrl + url);
    print(uri.toString());

    final request = http.MultipartRequest('PUT', uri);
    request.files.add(http.MultipartFile.fromString(
      'user',
      jsonEncode(body.toJson()),
      contentType: MediaType('application', 'json'),
      filename: "user",
    ));
    request.headers.addAll(headers);
    var res = await request.send();
    final response = await res.stream.bytesToString();
    if (res.statusCode == 200) {
      User user = User.fromJson(json.decode(response));
      return user;
    } else {
      final error = ErrorResponse.fromJson(json.decode(response));
      throw error;
    }
  }
    Future<dynamic> multipartRequestGeneric(String url, dynamic body,String nameBody) async {
    Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${box.read('token')}'
    };

    Uri uri = Uri.parse(ApiConstants.baseUrl + url);
    print(uri.toString());

    final request = http.MultipartRequest('POST', uri);
    request.files.add(http.MultipartFile.fromString(
      '${nameBody}',
      jsonEncode(body.toJson()),
      contentType: MediaType('application', 'json'),
      filename: "${nameBody}",
    ));
    request.headers.addAll(headers);
    var res = await request.send();
    final response = await res.stream.bytesToString();
    if (res.statusCode == 200) {
      MangaResponse manga = MangaResponse.fromJson(json.decode(response));
      return manga;
    } else {
      final error = ErrorResponse.fromJson(json.decode(response));
      throw error;
    }
  }


  Future<dynamic> multipartRequestFile(
      String url, String filename, String tipo) async {
    Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ${box.read('token')}'
    };

    Uri uri = Uri.parse(ApiConstants.baseUrl + url);
    print(uri.toString());

    final request = http.MultipartRequest('PUT', uri);
    request.files.add(await http.MultipartFile.fromPath(tipo, filename));

    request.headers.addAll(headers);
    var res = await request.send();
    final response = await res.stream.bytesToString();
    if (res.statusCode == 200) {
      User user = User.fromJson(json.decode(response));
      return user;
    } else {
      final error = ErrorResponse.fromJson(json.decode(response));
      throw error;
    }
  }

  dynamic _response(http.Response response) {
    print(response.statusCode);
    switch (response.statusCode) {
      case 200:
      case 201:
        var responseJson = utf8.decode(response.bodyBytes);
        return responseJson;
      case 204:
        return;
      case 400:
        if (response.body.isNotEmpty) {
          throw ErrorResponse.fromJson(jsonDecode(response.body));
        } else {
          throw BadRequestException();
        }
      case 401:
        if (response.body.isNotEmpty) {
          throw LoginError.fromJson(jsonDecode(response.body));
        } else {
          throw AuthenticationException(utf8.decode(response.bodyBytes));
        }
      case 403:
        throw UnauthorizedException(utf8.decode(response.bodyBytes));
      case 404:
        throw NotFoundException(utf8.decode(response.bodyBytes));
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}

class CustomException implements Exception {
  final _message;
  final _prefix;

  CustomException([this._message, this._prefix]);

  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends CustomException {
  FetchDataException([String? message]) : super(message, "");
}

class BadRequestException extends CustomException {
  BadRequestException([message]) : super(message, "");
}

class AuthenticationException extends CustomException {
  AuthenticationException([message]) : super(message, "");
}

class UnauthorizedException extends CustomException {
  UnauthorizedException([message]) : super(message, "");
}

class NotFoundException extends CustomException {
  NotFoundException([message]) : super(message, "");
}

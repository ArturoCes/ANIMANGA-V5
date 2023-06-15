import 'dart:convert';

import 'package:animangav4frontend/models/cart.dart';
import 'package:animangav4frontend/models/edit_user_dto.dart';
import 'package:animangav4frontend/models/password_dto.dart';
import 'package:animangav4frontend/models/purchaseDto.dart';
import 'package:animangav4frontend/models/purchaseResponse.dart';
import 'package:animangav4frontend/models/user.dart';
import 'package:animangav4frontend/rest/rest_client.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:injectable/injectable.dart';

@Order(4)
@singleton
class UserRepository {
  late RestClient _client;
  final box = GetStorage();
  UserRepository() {
    _client = GetIt.I.get<RestClient>();
  }

  Future<dynamic> uploadImage(String filename, String id, String tipo) async {
    String url = "/image/${id}";

    var jsonResponse = await _client.multipartRequestFile(url, filename, tipo);
    return jsonResponse;
  }

  Future<dynamic> userLogged() async {
    String url = "/me";

    Map<String, String> headers = {
      'Authorization': 'Bearer ${box.read('token')}'
    };
    var jsonResponse = await _client.get(url, headers: headers);
    return User.fromJson(jsonDecode(jsonResponse));
  }

  Future<dynamic> edit(EditUserDto editUserDto) async {
    String url = "/user/${box.read('idUser')}";

    var jsonResponse = await _client.multipartRequest(url, editUserDto);
    return jsonResponse;
  }

  Future<dynamic> editPassword(PasswordDto passwordDto) async {
    String url = "/change";

    var jsonResponse = await _client.multipartRequest(url, passwordDto);
    return jsonResponse;
  }

  Future<dynamic> addVolumenToCart(String idUser, String idVolumen) async {
    String url = "/cart/${idUser}/items/${idVolumen}";
    Map<String, String> headers = {
      'Authorization': 'Bearer ${box.read('token')}'
    };
    var jsonResponse = await _client.post2(url, headers: headers);
    return jsonResponse;
  }

   Future<dynamic>removeVolumenFromCart(String idUser, String idVolumen) async {
   String url = "/cart/${idUser}/items/remove/${idVolumen}";
    Map<String, String> headers = {
      'Authorization': 'Bearer ${box.read('token')}'
    };

    var jsonResponse = await _client.post2(url, headers: headers);
    return jsonResponse;

  }

  Future<dynamic>findAllVolumesFromCart(String idCart) async {
    String url =  "/cart/${idCart}";
    Map<String, String> headers = {
      'Authorization': 'Bearer ${box.read('token')}'
    };

    var jsonResponse = await _client.get(url, headers: headers);
    return CartResponse.fromJson(jsonDecode(jsonResponse));
  }

  Future<dynamic>purchase(PurchaseDto purchaseDto) async {
    String url =  "/purchase/new";
    Map<String, String> headers = {
      'Authorization': 'Bearer ${box.read('token')}'
    };

    var jsonResponse = await _client.post3(url, headers, purchaseDto);
    return  PurchaseResponse.fromJson(jsonDecode(jsonResponse));
  }
}

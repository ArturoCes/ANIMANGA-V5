import 'dart:convert';
//import 'dart:developer';

import 'package:animangav4frontend/blocs/login/login_dto.dart';
import 'package:animangav4frontend/blocs/register/bloc/register_dto.dart';
import 'package:animangav4frontend/models/edit_user_dto.dart';
import 'package:animangav4frontend/models/login.dart';
import 'package:animangav4frontend/models/models.dart';
import 'package:animangav4frontend/models/user.dart';
import 'package:animangav4frontend/repositories/AuthenticationRepository.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'localstorage_service.dart';

abstract class AuthenticationService {
  Future<LoginResponse?> getCurrentUser();
  Future<LoginResponse?> signInWithEmailAndPassword(LoginDto loginDto);
  Future<RegisterResponse?> register(RegisterDto registerDto);
  Future<void> signOut();

}

@Order(2)
@singleton
class JwtAuthenticationService extends AuthenticationService {
  late AuthenticationRepository _authenticationRepository;
  late LocalStorageService _localStorageService;

  JwtAuthenticationService() {
    _authenticationRepository = GetIt.I.get<AuthenticationRepository>();
    GetIt.I
        .getAsync<LocalStorageService>()
        .then((value) => _localStorageService = value);
  }

  @override
  Future<LoginResponse?> getCurrentUser() async {
    String? loggedUser = _localStorageService.getFromDisk("user");
    if (loggedUser != null) {
      var user = LoginResponse.fromJson(jsonDecode(loggedUser));
      return user;
    }
    return null;
  }

  @override
  Future<LoginResponse> signInWithEmailAndPassword(LoginDto loginDto) async {
    LoginResponse response = await _authenticationRepository.doLogin(loginDto);
    await _localStorageService.saveToDisk(
        'user', jsonEncode(response.toJson()));
    return response;
  }

  @override
  Future<RegisterResponse?> register(RegisterDto registerDto) async {
    RegisterResponse response =
        await _authenticationRepository.doRegister(registerDto);
        await _localStorageService.saveToDisk(
        'user', jsonEncode(response.toJson()));
    return response;
  }

  @override
  Future<void> signOut() async {
    await _localStorageService.deleteFromDisk("user");
  }

  
}

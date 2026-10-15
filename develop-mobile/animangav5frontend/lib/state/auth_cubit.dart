import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../data/models.dart';
import '../data/repositories.dart';

sealed class AuthState {
  const AuthState();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Unauthenticated extends AuthState {
  const Unauthenticated({this.message});

  /// Mensaje opcional a mostrar en la pantalla de login (p. ej. sesión caducada).
  final String? message;
}

class Authenticated extends AuthState {
  const Authenticated(this.user);
  final User user;
}

/// Gestiona la sesión y la persiste entre arranques.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._api, this._repo) : super(const AuthLoading()) {
    _api.onUnauthorized = () => logout(message: 'Tu sesión ha caducado. Vuelve a iniciar sesión.');
  }

  static const _tokenKey = 'token';
  static const _userKey = 'user';

  final ApiClient _api;
  final AuthRepository _repo;

  User? get user => switch (state) {
        Authenticated(:final user) => user,
        _ => null,
      };

  /// Restaura la sesión guardada y comprueba que el token siga siendo válido.
  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final rawUser = prefs.getString(_userKey);
    if (token == null || rawUser == null) return emit(const Unauthenticated());

    _api.token = token;
    emit(Authenticated(User.fromJson(jsonDecode(rawUser) as Map<String, dynamic>)));
    try {
      await updateUser(await _repo.me());
    } on ApiException catch (e) {
      if (e.isUnauthorized) await logout();
    }
  }

  Future<void> login(String username, String password) async {
    final user = await _repo.login(username, password);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, _api.token!);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    emit(Authenticated(user));
  }

  Future<void> register({
    required String username,
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _repo.register(username: username, fullName: fullName, email: email, password: password);
    await login(username, password);
  }

  Future<void> updateUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    emit(Authenticated(user));
  }

  Future<void> logout({String? message}) async {
    _api.token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    emit(Unauthenticated(message: message));
  }
}

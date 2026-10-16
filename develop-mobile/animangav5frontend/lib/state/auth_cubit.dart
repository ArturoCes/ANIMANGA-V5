import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../data/models.dart';
import '../data/repositories.dart';

class AuthState {
  const AuthState({this.user, this.loading = false, this.message});

  /// `null` = invitado (se puede navegar por el catálogo sin cuenta).
  final User? user;
  final bool loading;

  /// Aviso para mostrar una vez (p. ej. sesión caducada).
  final String? message;

  bool get isLoggedIn => user != null;
}

/// Sesión del usuario. Guarda los tokens entre arranques y se entera de las renovaciones.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._api, this._repo) : super(const AuthState(loading: true)) {
    _api.onSessionRefreshed = (session) => _saveSession(session);
    _api.onSessionExpired = () => _clear(message: 'Tu sesión ha caducado. Vuelve a iniciar sesión.');
  }

  static const _accessKey = 'access';
  static const _refreshKey = 'refresh';
  static const _userKey = 'user';

  final ApiClient _api;
  final AuthRepository _repo;

  User? get user => state.user;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString(_accessKey);
    final refresh = prefs.getString(_refreshKey);
    final rawUser = prefs.getString(_userKey);
    if (access == null || refresh == null || rawUser == null) return emit(const AuthState());

    _api.session = Session(access, refresh);
    emit(AuthState(user: User.fromJson(jsonDecode(rawUser) as Map<String, dynamic>)));
    try {
      await updateUser(await _repo.me());
    } on ApiException catch (e) {
      if (e.isUnauthorized) await _clear();
    }
  }

  Future<void> login(String username, String password) async {
    final (user, session) = await _repo.login(username, password);
    await _start(user, session);
  }

  Future<void> register({
    required String username,
    required String fullName,
    required String email,
    required String password,
  }) async {
    final (user, session) =
        await _repo.register(username: username, fullName: fullName, email: email, password: password);
    await _start(user, session);
  }

  Future<void> updateUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    emit(AuthState(user: user));
  }

  Future<void> logout() async {
    final refresh = _api.session?.refreshToken;
    if (refresh != null) _repo.logout(refresh).ignore();
    await _clear();
  }

  void consumeMessage() {
    if (state.message != null) emit(AuthState(user: state.user));
  }

  Future<void> _start(User user, Session session) async {
    _api.session = session;
    await _saveSession(session);
    await updateUser(user);
  }

  Future<void> _saveSession(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, session.accessToken);
    await prefs.setString(_refreshKey, session.refreshToken);
  }

  Future<void> _clear({String? message}) async {
    _api.session = null;
    final prefs = await SharedPreferences.getInstance();
    for (final key in [_accessKey, _refreshKey, _userKey]) {
      await prefs.remove(key);
    }
    emit(AuthState(message: message));
  }
}

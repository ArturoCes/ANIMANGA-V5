import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tema claro, oscuro o el del sistema; se recuerda entre sesiones.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  static const _key = 'themeMode';

  Future<void> restore() async {
    final saved = (await SharedPreferences.getInstance()).getString(_key);
    emit(ThemeMode.values.firstWhere((m) => m.name == saved, orElse: () => ThemeMode.system));
  }

  Future<void> set(ThemeMode mode) async {
    emit(mode);
    await (await SharedPreferences.getInstance()).setString(_key, mode.name);
  }
}

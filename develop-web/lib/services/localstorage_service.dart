// ignore_for_file: unnecessary_null_comparison

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  const LocalStorageService();

  static late LocalStorageService _instance;
  static late SharedPreferences _preferences;

  static Future<LocalStorageService> getInstance() async {
    print("Aquí se entra");

    _preferences = await SharedPreferences.getInstance();

    print("Aquí se llega");

    _instance = LocalStorageService();

    return _instance;
  }

  dynamic getFromDisk(String key) {
    var value = _preferences.get(key);
    return value;
  }

  Future<void> saveToDisk<T>(String key, T content) async {
    if (content is String) {
      await _preferences.setString(key, content);
    }
    if (content is bool) {
      await _preferences.setBool(key, content);
    }
    if (content is int) {
      await _preferences.setInt(key, content);
    }
    if (content is double) {
      await _preferences.setDouble(key, content);
    }
    if (content is List<String>) {
      await _preferences.setStringList(key, content);
    }
  }

  Future<void> deleteFromDisk(String key) async {
    await _preferences.remove(key);
  }
}

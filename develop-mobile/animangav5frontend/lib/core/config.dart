import 'package:flutter/foundation.dart';

/// Configuración de la URL de la API.
///
/// Se puede fijar al compilar: `--dart-define=API_URL=https://mi-api.com`.
/// Si no se indica:
///  - en web se usa `/api` del mismo dominio (el hosting hace de proxy),
///  - en Android se usa el emulador (`10.0.2.2` apunta al localhost del PC),
///  - en el resto, `localhost:8080`.
class AppConfig {
  static const _fromEnv = String.fromEnvironment('API_URL');

  static final String apiUrl = _resolve();

  static String _resolve() {
    if (_fromEnv.isNotEmpty) return _trim(_fromEnv);
    if (kIsWeb) return '${Uri.base.origin}/api';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  static String _trim(String url) => url.endsWith('/') ? url.substring(0, url.length - 1) : url;

  /// URL de una imagen servida por la API (`/download/{fichero}`).
  static String imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$apiUrl/download/${Uri.encodeComponent(path)}';
  }
}

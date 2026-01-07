import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static const String _defaultWebBaseUrl = 'http://localhost:3000';
  static const String _defaultAndroidEmulatorBaseUrl = 'http://10.0.2.2:3000';
  static const String _defaultAndroidDeviceBaseUrl = 'http://192.168.100.204:3000';
  static const String _defaultOtherBaseUrl = 'http://localhost:3000';

  static String? _resolvedBaseUrl;

  /// Inicializa a configuração de API.
  ///
  /// Recomendo chamar em `main()` (após `dotenv.load`) para que a URL fique
  /// pronta antes de qualquer request.
  static Future<void> initialize() async {
    _resolvedBaseUrl = await _resolveBaseUrl();
  }

  static String get baseUrl {
    final cached = _resolvedBaseUrl;
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    // Fallback defensivo caso initialize() não tenha sido chamado.
    // Não detecta emulador vs device físico (isso exige async).
    final definedBaseUrl = const String.fromEnvironment('API_BASE_URL');
    if (definedBaseUrl.trim().isNotEmpty) {
      return _normalize(definedBaseUrl);
    }

    final env = dotenv.env;

    final platformBaseUrl = kIsWeb
        ? (env['API_BASE_URL_WEB'] ?? env['API_BASE_URL'])
        : (defaultTargetPlatform == TargetPlatform.android
            ? (env['API_BASE_URL_ANDROID'] ?? env['API_BASE_URL'])
            : env['API_BASE_URL']);

    final fallback = kIsWeb
        ? _defaultWebBaseUrl
        : (defaultTargetPlatform == TargetPlatform.android
            ? _defaultAndroidEmulatorBaseUrl
            : _defaultOtherBaseUrl);

    final resolved = (platformBaseUrl == null || platformBaseUrl.trim().isEmpty)
        ? fallback
        : platformBaseUrl.trim();

    return _normalize(resolved);
  }

  static Uri uri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath');
  }

  static String _normalize(String raw) {
    var value = raw.trim();

    if (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }

    return value;
  }

  static Future<String> _resolveBaseUrl() async {
    final definedBaseUrl = const String.fromEnvironment('API_BASE_URL');
    if (definedBaseUrl.trim().isNotEmpty) {
      return _normalize(definedBaseUrl);
    }

    final env = dotenv.env;

    if (kIsWeb) {
      final base = env['API_BASE_URL_WEB'] ?? env['API_BASE_URL'] ?? _defaultWebBaseUrl;
      return _normalize(base);
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final isPhysicalDevice = await _isPhysicalAndroidDevice();

      final baseRaw = isPhysicalDevice
          ? (env['API_BASE_URL_ANDROID_DEVICE'] ??
              env['API_BASE_URL_ANDROID'] ??
              env['API_BASE_URL'] ??
              _defaultAndroidDeviceBaseUrl)
          : (env['API_BASE_URL_ANDROID_EMULATOR'] ??
              env['API_BASE_URL_ANDROID'] ??
              env['API_BASE_URL'] ??
              _defaultAndroidEmulatorBaseUrl);

      final normalized = _normalize(baseRaw);

      // Só o emulador entende 10.0.2.2. Em device físico, NUNCA aplicar isso.
      if (!isPhysicalDevice && normalized.contains('localhost')) {
        return normalized.replaceFirst('localhost', '10.0.2.2');
      }

      return normalized;
    }

    final base = env['API_BASE_URL'] ?? _defaultOtherBaseUrl;
    return _normalize(base);
  }

  static Future<bool> _isPhysicalAndroidDevice() async {
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      return info.isPhysicalDevice;
    } catch (_) {
      // Em caso de falha na leitura, assumimos device físico (mais seguro)
      // para evitar tentar 10.0.2.2.
      return true;
    }
  }
}

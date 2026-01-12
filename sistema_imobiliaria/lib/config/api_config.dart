import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static const String _defaultWebBaseUrl = 'https://sistema-imobiliaria.onrender.com';
  static const String _defaultAndroidEmulatorBaseUrl = 'https://sistema-imobiliaria.onrender.com';
  static const String _defaultAndroidDeviceBaseUrl = 'https://sistema-imobiliaria.onrender.com';
  static const String _defaultOtherBaseUrl = 'https://sistema-imobiliaria.onrender.com';

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

    // Fallback defensivo síncrono - prioridade absoluta para Web
    final definedBaseUrl = const String.fromEnvironment('API_BASE_URL');
    if (definedBaseUrl.trim().isNotEmpty) {
      return _normalize(definedBaseUrl);
    }

    final env = dotenv.env;

    // Web tem prioridade absoluta
    if (kIsWeb) {
      return _normalize(env['API_BASE_URL_WEB'] ?? env['API_BASE_URL'] ?? _defaultWebBaseUrl);
    }

    // Android: assumir device físico por segurança (não podemos detectar async aqui)
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _normalize(env['API_BASE_URL_ANDROID_DEVICE'] ?? 
                       env['API_BASE_URL_ANDROID'] ?? 
                       env['API_BASE_URL'] ?? 
                       _defaultAndroidDeviceBaseUrl);
    }

    // Outras plataformas
    return _normalize(env['API_BASE_URL'] ?? _defaultOtherBaseUrl);
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

    // Web tem prioridade absoluta - ignora defaultTargetPlatform
    if (kIsWeb) {
      final base = env['API_BASE_URL_WEB'] ?? env['API_BASE_URL'] ?? _defaultWebBaseUrl;
      print('DEBUG Web: env[API_BASE_URL_WEB] = ${env['API_BASE_URL_WEB']}');
      print('DEBUG Web: env[API_BASE_URL] = ${env['API_BASE_URL']}');
      print('DEBUG Web: base final = $base');
      return _normalize(base);
    }

    // Só executa lógica Android se NÃO for Web
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
      if (isPhysicalDevice &&
          (normalized.contains('localhost') || normalized.contains('127.0.0.1'))) {
        final forced = env['API_BASE_URL_ANDROID_DEVICE'] ?? _defaultAndroidDeviceBaseUrl;
        return _normalize(forced);
      }

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

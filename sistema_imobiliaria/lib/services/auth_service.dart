import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class AuthService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      colors: true,
      printEmojis: true,
    ),
  );

  // Token atual em memória (fallback rápido)
  static String? _currentToken;
  
  // Usar SharedPreferences como fallback (mais simples que secure_storage)
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';

  /// Salva o token de autenticação
  static Future<void> saveToken(String token, {
    int? userId,
    String? email,
    String? name,
  }) async {
    try {
      _currentToken = token;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      
      if (userId != null) {
        await prefs.setInt(_userIdKey, userId);
      }
      if (email != null) {
        await prefs.setString(_userEmailKey, email);
      }
      if (name != null) {
        await prefs.setString(_userNameKey, name);
      }
      
      _logger.i('Token salvo com sucesso');
    } catch (e) {
      _logger.e('Erro ao salvar token', error: e);
      // Continua mesmo se falhar (token em memória ainda funciona)
    }
  }

  /// Obtém o token de autenticação
  static Future<String?> getToken() async {
    // Primeiro tenta memória (mais rápido)
    if (_currentToken != null) {
      return _currentToken;
    }
    
    // Se não tiver em memória, busca do storage
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null) {
        _currentToken = token;
        return token;
      }
    } catch (e) {
      _logger.w('Erro ao buscar token do storage', error: e);
    }
    
    return null;
  }

  /// Obtém o token de forma síncrona (se já estiver em memória)
  static String? getTokenSync() {
    return _currentToken;
  }

  /// Remove o token (logout)
  static Future<void> clearToken() async {
    try {
      _currentToken = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userNameKey);
      
      _logger.i('Token removido (logout)');
    } catch (e) {
      _logger.e('Erro ao remover token', error: e);
    }
  }

  /// Verifica se o usuário está autenticado
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Obtém informações do usuário salvas
  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(_userIdKey);
      final email = prefs.getString(_userEmailKey);
      final name = prefs.getString(_userNameKey);
      
      if (userId == null) return null;
      
      return {
        'id': userId,
        'email': email,
        'name': name,
      };
    } catch (e) {
      _logger.e('Erro ao buscar informações do usuário', error: e);
      return null;
    }
  }
}

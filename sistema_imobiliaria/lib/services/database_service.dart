import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class DatabaseService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      colors: true,
      printEmojis: true,
    ),
  );
  
  static String _baseUrl = 'http://localhost:3000';
  static bool _initialized = false;

  // Inicializa o serviço
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      await dotenv.load(fileName: '.env');
      final url = dotenv.env['API_BASE_URL'];
      final defaultBaseUrl = kIsWeb
          ? 'http://localhost:3000'
          : (defaultTargetPlatform == TargetPlatform.android
              ? 'http://10.0.2.2:3000'
              : 'http://localhost:3000');
      final baseUrlRaw = (url == null || url.isEmpty) ? defaultBaseUrl : url;
      final baseUrlAndroidAdjusted = (!kIsWeb &&
              defaultTargetPlatform == TargetPlatform.android &&
              baseUrlRaw.contains('localhost'))
          ? baseUrlRaw.replaceFirst('localhost', '10.0.2.2')
          : baseUrlRaw;
      _baseUrl = baseUrlAndroidAdjusted.endsWith('/')
          ? baseUrlAndroidAdjusted.substring(0, baseUrlAndroidAdjusted.length - 1)
          : baseUrlAndroidAdjusted;
      _logger.i('DatabaseService inicializado com URL: $_baseUrl');
      _initialized = true;
    } catch (e, stackTrace) {
      _logger.e('Erro ao inicializar DatabaseService', error: e, stackTrace: stackTrace);
      // Continua com o valor padrão
    }
  }

  // Simulação de banco de dados em memória (backup)
  static final List<Map<String, dynamic>> _imoveis = [];
  static final List<Map<String, dynamic>> _locadores = [];
  static final List<Map<String, dynamic>> _locatarios = [];

  // Helper para compatibilidade de campos
  static void _ensureCompatibility(Map<String, dynamic> item) {
    if (item.containsKey('nome') && !item.containsKey('name')) {
      item['name'] = item['nome'];
    }
  }

  // Helper para requisições HTTP
  static Future<Map<String, dynamic>> _makeRequest(
    String method, 
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    if (!_initialized) await initialize();
    
    final stopwatch = Stopwatch()..start();
    final String requestId = '${DateTime.now().millisecondsSinceEpoch}';
    
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      _logger.d('[$requestId] $method $uri');

      if (!uri.isAbsolute) {
        throw Exception('URL inválida: $uri');
      }

      http.Response response;
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Access-Control-Allow-Origin': '*',
      };

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers)
              .timeout(const Duration(seconds: 15));
          break;
          
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          ).timeout(const Duration(seconds: 15));
          break;
          
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          ).timeout(const Duration(seconds: 15));
          break;
          
        case 'DELETE':
          response = await http.delete(uri, headers: headers)
              .timeout(const Duration(seconds: 15));
          break;
          
        default:
          throw Exception('Método HTTP não suportado: $method');
      }

      stopwatch.stop();
      _logger.i('[$requestId] ${response.statusCode} ${response.request?.url.path} (${stopwatch.elapsedMilliseconds}ms)');

      if (response.statusCode >= 500) {
        throw HttpException(
          'Erro no servidor (${response.statusCode})',
          uri: uri,
        );
      }

      if (response.body.isEmpty) {
        return {};
      }

      try {
        final responseData = jsonDecode(response.body);
        
        if (response.statusCode >= 400) {
          final errorMsg = responseData['message'] ?? 'Erro na requisição';
          throw Exception('$errorMsg (${response.statusCode})');
        }

        return responseData;
      } on FormatException catch (e) {
        _logger.e('Erro ao decodificar resposta JSON: ${e.message}');
        return {'data': response.body};
      }
      
    } on SocketException catch (e) {
      stopwatch.stop();
      _logger.e('[$requestId] Erro de conexão: ${e.message}');
      throw Exception('Sem conexão com a internet. Verifique sua conexão e tente novamente.');
      
    } on http.ClientException catch (e) {
      stopwatch.stop();
      _logger.e('[$requestId] Erro na requisição HTTP: ${e.message}');
      throw Exception('Erro na comunicação com o servidor. Tente novamente mais tarde.');
      
    } on TimeoutException {
      stopwatch.stop();
      _logger.e('[$requestId] Timeout na requisição');
      throw Exception('O servidor demorou muito para responder. Tente novamente mais tarde.');
      
    } catch (e, stackTrace) {
      stopwatch.stop();
      _logger.e('[$requestId] Erro inesperado', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Adicionar Locador
  static Future<void> addLocador(Map<String, dynamic> locador) async {
    if (!_initialized) await initialize();
    
    try {
      _logger.d('Tentando adicionar locador');
      _logger.d('Dados do locador: $locador');
      
      _validateLocadorData(locador);
      final response = await _makeRequest('POST', '/locadores', body: locador);
      
      _logger.d('Resposta da API: $response');
      
      final newLocador = Map<String, dynamic>.from(locador);
      newLocador['id'] = response['data']?['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      newLocador['createdAt'] = DateTime.now().toIso8601String();
      _locadores.add(newLocador);
      
      _logger.i('Locador adicionado: ${locador['name'] ?? locador['nome'] ?? 'Sem nome'}');
    } catch (e, stackTrace) {
      _logger.e('Erro ao adicionar locador', error: e, stackTrace: stackTrace);
      
      // Fallback para modo local
      locador['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      locador['createdAt'] = DateTime.now().toIso8601String();
      _locadores.add(locador);
      _logger.i('Locador adicionado localmente: ${locador['name'] ?? locador['nome'] ?? 'Sem nome'}');
    }
  }
  
  // Valida os dados do locador
  static void _validateLocadorData(Map<String, dynamic> data) {
    if (data['name'] == null && data['nome'] == null) {
      throw Exception('O campo nome é obrigatório');
    }
    // Adicione outras validações conforme necessário
  }

  // Adicionar Locatário
  static Future<void> addLocatario(Map<String, dynamic> locatario) async {
    if (!_initialized) await initialize();
    try {
      _logger.d('Tentando adicionar locatário');
      _logger.d('Dados do locatário: $locatario');
      
      final response = await _makeRequest('POST', '/locatarios', body: locatario);
      
      _logger.d('Resposta da API: $response');
      
      // Adicionar localmente para sincronia
      final newLocatario = Map<String, dynamic>.from(locatario);
      newLocatario['id'] = response['data']['id'].toString();
      newLocatario['createdAt'] = DateTime.now().toIso8601String();
      _locatarios.add(newLocatario);
      
      _logger.i('Locatário adicionado com sucesso: ${locatario['nome']}');
    } catch (e, stackTrace) {
      // Fallback para modo local
      locatario['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      locatario['createdAt'] = DateTime.now().toIso8601String();
      _locatarios.add(locatario);
      _logger.e('Erro ao adicionar locatário; usando fallback local', error: e, stackTrace: stackTrace);
      _logger.i('Locatário adicionado localmente (fallback): ${locatario['nome']}');
    }
  }

  // Adicionar Imóvel
  static Future<void> addImovel(Map<String, dynamic> imovel) async {
    if (!_initialized) await initialize();
    try {
      final response = await _makeRequest('POST', '/imoveis', body: imovel);
      
      // Adicionar localmente para sincronia
      final newImovel = Map<String, dynamic>.from(imovel);
      newImovel['id'] = response['data']['id'].toString();
      newImovel['createdAt'] = DateTime.now().toIso8601String();
      _imoveis.add(newImovel);
      
      _logger.i('Imóvel adicionado: ${imovel['endereco']}');
    } catch (e) {
      // Fallback para modo local
      imovel['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      imovel['createdAt'] = DateTime.now().toIso8601String();
      _imoveis.add(imovel);
      _logger.e('Erro ao adicionar imóvel; usando fallback local', error: e);
      _logger.i('Imóvel adicionado localmente: ${imovel['endereco']}');
    }
  }

  // Obter todos os locadores
  static Future<List<Map<String, dynamic>>> getLocadores() async {
    if (!_initialized) await initialize();
    
    try {
      final response = await _makeRequest('GET', '/locadores');
      final List<dynamic> data = response['data'] ?? [];
      
      // Atualizar cache local
      _locadores.clear();
      for (var item in data) {
        try {
          final locador = Map<String, dynamic>.from(item);
          _ensureCompatibility(locador);
          _locadores.add(locador);
        } catch (e) {
          _logger.e('Erro ao processar item de locador', error: e);
        }
      }
      
      _logger.i('${_locadores.length} locadores carregados');
      return List.from(_locadores);
    } catch (e, stackTrace) {
      _logger.e('Erro ao buscar locadores, usando cache local', error: e, stackTrace: stackTrace);
      return List.from(_locadores);
    }
  }

  // Obter todos os locatários
  static Future<List<Map<String, dynamic>>> getLocatarios() async {
    try {
      final response = await _makeRequest('GET', '/locatarios');
      final List<dynamic> data = response['data'];
      
      // Atualizar cache local
      _locatarios.clear();
      for (var item in data) {
        final locatario = Map<String, dynamic>.from(item);
        _ensureCompatibility(locatario);
        _locatarios.add(locatario);
      }
      
      return List.from(_locatarios);
    } catch (e) {
      _logger.w('Usando dados locais para locatários', error: e);
      return List.from(_locatarios);
    }
  }

  // Obter todos os imóveis
  static Future<List<Map<String, dynamic>>> getImoveis() async {
    try {
      final response = await _makeRequest('GET', '/imoveis');
      final List<dynamic> data = response['data'];
      
      // Atualizar cache local
      _imoveis.clear();
      for (var item in data) {
        _imoveis.add(Map<String, dynamic>.from(item));
      }
      
      return List.from(_imoveis);
    } catch (e) {
      _logger.w('Usando dados locais para imóveis', error: e);
      return List.from(_imoveis);
    }
  }

  // Obter locador por ID
  static Future<Map<String, dynamic>?> getLocadorById(String id) async {
    try {
      final response = await _makeRequest('GET', '/locadores/$id');
      final locador = Map<String, dynamic>.from(response['data']);
      _ensureCompatibility(locador);
      return locador;
    } catch (e) {
      // Fallback para busca local
      try {
        final found = _locadores.firstWhere((locador) => locador['id'] == id);
        _ensureCompatibility(found);
        return found;
      } catch (e) {
        return null;
      }
    }
  }

  // Obter locatário por ID
  static Future<Map<String, dynamic>?> getLocatarioById(String id) async {
    try {
      final response = await _makeRequest('GET', '/locatarios/$id');
      final locatario = Map<String, dynamic>.from(response['data']);
      _ensureCompatibility(locatario);
      return locatario;
    } catch (e) {
      // Fallback para busca local
      try {
        final found = _locatarios.firstWhere((locatario) => locatario['id'] == id);
        _ensureCompatibility(found);
        return found;
      } catch (e) {
        return null;
      }
    }
  }

  // Atualizar locador
  static Future<void> updateLocador(String id, Map<String, dynamic> data) async {
    try {
      await _makeRequest('PUT', '/locadores/$id', body: data);
      
      // Atualizar cache local
      final index = _locadores.indexWhere((locador) => locador['id'] == id);
      if (index != -1) {
        _locadores[index] = {..._locadores[index], ...data};
        _locadores[index]['updatedAt'] = DateTime.now().toIso8601String();
      }
      
      _logger.i('Locador atualizado: $id');
    } catch (e) {
      // Fallback para modo local
      final index = _locadores.indexWhere((locador) => locador['id'] == id);
      if (index != -1) {
        _locadores[index] = {..._locadores[index], ...data};
        _locadores[index]['updatedAt'] = DateTime.now().toIso8601String();
        _logger.w('Locador atualizado localmente: $id', error: e);
      }
    }
  }

  // Atualizar locatário
  static Future<void> updateLocatario(String id, Map<String, dynamic> data) async {
    try {
      await _makeRequest('PUT', '/locatarios/$id', body: data);
      
      // Atualizar cache local
      final index = _locatarios.indexWhere((locatario) => locatario['id'] == id);
      if (index != -1) {
        _locatarios[index] = {..._locatarios[index], ...data};
        _locatarios[index]['updatedAt'] = DateTime.now().toIso8601String();
      }
      
      _logger.i('Locatário atualizado: $id');
    } catch (e) {
      // Fallback para modo local
      final index = _locatarios.indexWhere((locatario) => locatario['id'] == id);
      if (index != -1) {
        _locatarios[index] = {..._locatarios[index], ...data};
        _locatarios[index]['updatedAt'] = DateTime.now().toIso8601String();
        _logger.w('Locatário atualizado localmente: $id', error: e);
      }
    }
  }

  // Excluir locador
  static Future<void> deleteLocador(String id) async {
    try {
      await _makeRequest('DELETE', '/locadores/$id');
      
      // Remover do cache local
      _locadores.removeWhere((locador) => locador['id'] == id);
      
      _logger.i('Locador excluído: $id');
    } catch (e) {
      // Fallback para modo local
      _locadores.removeWhere((locador) => locador['id'] == id);
      _logger.w('Locador excluído localmente: $id', error: e);
    }
  }

  // Excluir locatário
  static Future<void> deleteLocatario(String id) async {
    try {
      await _makeRequest('DELETE', '/locatarios/$id');
      
      // Remover do cache local
      _locatarios.removeWhere((locatario) => locatario['id'] == id);
      
      _logger.i('Locatário excluído: $id');
    } catch (e) {
      // Fallback para modo local
      _locatarios.removeWhere((locatario) => locatario['id'] == id);
      _logger.w('Locatário excluído localmente: $id', error: e);
    }
  }

  // Estatísticas
  static Future<Map<String, dynamic>> getStatistics() async {
    if (!_initialized) await initialize();
    
    try {
      final response = await _makeRequest('GET', '/estatisticas');
      final data = response['data'] ?? {};
      
      _logger.i('Estatísticas carregadas: $data');
      return {
        'imoveis': data['imoveis'] ?? 0,
        'locadores': data['locadores'] ?? 0,
        'locatarios': data['locatarios'] ?? 0,
        'lastUpdated': DateTime.now().toIso8601String(),
        'source': 'remote',
      };
    } catch (e, stackTrace) {
      _logger.e('Erro ao buscar estatísticas, usando dados locais', error: e, stackTrace: stackTrace);
      
      return {
        'imoveis': _imoveis.length,
        'locadores': _locadores.length,
        'locatarios': _locatarios.length,
        'lastUpdated': DateTime.now().toIso8601String(),
        'source': 'local',
      };
    }
  }
  
  // Testa a conexão com a API
  static Future<Map<String, dynamic>> testConnection() async {
    if (!_initialized) await initialize();
    
    try {
      final stopwatch = Stopwatch()..start();
      final response = await _makeRequest('GET', '/');
      stopwatch.stop();
      
      return {
        'success': true,
        'status': 'connected',
        'responseTime': '${stopwatch.elapsedMilliseconds}ms',
        'message': response['message'] ?? 'ok',
      };
    } catch (e, stackTrace) {
      _logger.e('Falha ao testar conexão com a API', error: e, stackTrace: stackTrace);
      
      return {
        'success': false,
        'status': 'disconnected',
        'error': e.toString(),
      };
    }
  }

  // Limpar todos os dados (para testes)
  static Future<void> clearAllData() async {
    if (!_initialized) await initialize();
    
    try {
      await _makeRequest('POST', '/clear-data');
      _logger.i('Dados do servidor limpos com sucesso');
    } catch (e) {
      _logger.e('Não foi possível limpar os dados do servidor', error: e);
    }
    
    _imoveis.clear();
    _locadores.clear();
    _locatarios.clear();
    _logger.i('Dados locais limpos');
  }
}

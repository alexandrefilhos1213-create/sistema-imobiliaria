import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class ImageService {
  static String get baseUrl => ApiConfig.baseUrl;

  static MediaType _guessMediaType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.gif')) return MediaType('image', 'gif');
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    return MediaType('image', 'jpeg');
  }

  // Fazer upload de múltiplas imagens para um imóvel
  static Future<Map<String, dynamic>> uploadImagens(int idImovel, List<XFile> imagens) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/imoveis/$idImovel/imagens'),
      );
      
      // Adicionar token de autenticação
      final token = await AuthService.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Adicionar todas as imagens ao request
      for (int i = 0; i < imagens.length; i++) {
        final imagem = imagens[i];
        final Uint8List bytes = await imagem.readAsBytes();
        
        request.files.add(
          http.MultipartFile.fromBytes(
            'imagens',
            bytes,
            filename: imagem.name.isNotEmpty ? imagem.name : 'imagem_$i.jpg',
            contentType: _guessMediaType(imagem.name),
          ),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      Map<String, dynamic>? payload;
      try {
        final decoded = json.decode(responseBody);
        if (decoded is Map<String, dynamic>) payload = decoded;
      } catch (_) {}

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': payload?['success'] ?? true,
          'data': payload?['data'] ?? [],
          'message': payload?['message'],
        };
      }
      return {
        'success': false,
        'message': payload?['message'] ?? 'Erro ao fazer upload: ${response.statusCode}',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Erro no upload de imagens: $e');
      }
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Buscar imagens de um imóvel
  static Future<Map<String, dynamic>> getImagens(int idImovel) async {
    try {
      final token = await AuthService.getToken();
      final headers = <String, String>{};
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/imoveis/$idImovel/imagens'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return {
            'success': decoded['success'] ?? true,
            'data': decoded['data'] ?? [],
            'message': decoded['message'],
          };
        }
        return {
          'success': true,
          'data': [],
        };
      } else {
        String? errorMessage;
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic>) {
            errorMessage = decoded['message']?.toString();
          }
        } catch (_) {}
        return {
          'success': false,
          'message': errorMessage ?? 'Erro ao buscar imagens: ${response.statusCode}',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar imagens: $e');
      }
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Remover uma imagem
  static Future<Map<String, dynamic>> removerImagem(int idImagem) async {
    try {
      final token = await AuthService.getToken();
      final headers = <String, String>{};
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.delete(
        Uri.parse('$baseUrl/imoveis-imagens/$idImagem'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return {
            'success': decoded['success'] ?? true,
            'data': decoded['data'],
            'message': decoded['message'],
          };
        }
        return {
          'success': true,
          'data': null,
        };
      } else {
        String? errorMessage;
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic>) {
            errorMessage = decoded['message']?.toString();
          }
        } catch (_) {}
        return {
          'success': false,
          'message': errorMessage ?? 'Erro ao remover imagem: ${response.statusCode}',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao remover imagem: $e');
      }
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Construir URL completa para imagem
  static String buildImageUrl(String caminhoImagem) {
    if (caminhoImagem.startsWith('http')) {
      return caminhoImagem;
    }
    return '$baseUrl$caminhoImagem';
  }
}

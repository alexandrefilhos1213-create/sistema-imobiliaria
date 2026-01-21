import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class ImageService {
  static String get baseUrl => ApiConfig.baseUrl;

  // Fazer upload de múltiplas imagens para um imóvel
  static Future<Map<String, dynamic>> uploadImagens(int idImovel, List<File> imagens) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/imoveis/$idImovel/imagens'),
      );
      
      // Adicionar token de autenticação
      final token = AuthService.getTokenSync();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Adicionar todas as imagens ao request
      for (int i = 0; i < imagens.length; i++) {
        File imagem = imagens[i];
        Uint8List bytes = await imagem.readAsBytes();
        
        request.files.add(
          http.MultipartFile.fromBytes(
            'imagens',
            bytes,
            filename: 'imagem_$i.jpg',
          ),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': json.decode(responseBody),
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ao fazer upload: ${response.statusCode}',
        };
      }
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
      final token = AuthService.getTokenSync();
      final headers = <String, String>{};
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/imoveis/$idImovel/imagens'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ao buscar imagens: ${response.statusCode}',
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
      final token = AuthService.getTokenSync();
      final headers = <String, String>{};
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.delete(
        Uri.parse('$baseUrl/imoveis-imagens/$idImagem'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ao remover imagem: ${response.statusCode}',
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

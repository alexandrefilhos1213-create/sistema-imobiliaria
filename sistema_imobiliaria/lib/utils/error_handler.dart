import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

enum LogLevel { debug, info, warning, error, wtf }

class ErrorHandler {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 3,
      errorMethodCount: 5,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// Inicializa os handlers de erro globais
  static void initialize() {
    // Captura erros assíncronos do Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      logError(
        details.exception,
        details.stack,
        'Erro no Flutter',
        LogLevel.error,
      );
    };

    // Captura erros fora do Flutter
    PlatformDispatcher.instance.onError = (error, stack) {
      logError(
        error,
        stack,
        'Erro na plataforma',
        LogLevel.error,
      );
      return true;
    };
  }

  /// Registra um erro no logger
  static void logError(
    dynamic error, [
    StackTrace? stackTrace,
    String? message,
    LogLevel? level,
  ]) {
    final errorMessage = message ?? 'Erro não tratado';
    final errorObject = error is Error ? error : Exception(error?.toString() ?? 'Erro desconhecido');
    
    switch (level ?? LogLevel.error) {
      case LogLevel.debug:
        _logger.d(errorMessage, error: errorObject, stackTrace: stackTrace);
        break;
      case LogLevel.info:
        _logger.i(errorMessage, error: errorObject, stackTrace: stackTrace);
        break;
      case LogLevel.warning:
        _logger.w(errorMessage, error: errorObject, stackTrace: stackTrace);
        break;
      case LogLevel.error:
        _logger.e(errorMessage, error: errorObject, stackTrace: stackTrace);
        break;
      case LogLevel.wtf:
        _logger.wtf(errorMessage, error: errorObject, stackTrace: stackTrace);
        break;
    }
    
    // Aqui você pode adicionar o envio do erro para um serviço de monitoramento
    // como Sentry, Firebase Crashlytics, etc.
    // Exemplo: _sendToCrashlytics(error, stackTrace, message);
  }

  /// Exibe um diálogo de erro para o usuário
  static void showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (actionText != null && onAction != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAction();
              },
              child: Text(actionText),
            ),
        ],
      ),
    );
  }

  /// Converte uma exceção em uma mensagem amigável
  static String getFriendlyErrorMessage(dynamic error) {
    try {
      if (error == null) return 'Erro desconhecido';
      if (error is String) return error;
      
      final errorMessage = error.toString();
      
      // Mapeia mensagens de erro comuns para mensagens mais amigáveis
      if (errorMessage.contains('SocketException') || 
          errorMessage.contains('Connection failed') ||
          errorMessage.contains('Failed host lookup')) {
        return 'Sem conexão com a internet. Verifique sua conexão e tente novamente.';
      } else if (errorMessage.contains('TimeoutException')) {
        return 'O servidor demorou muito para responder. Tente novamente mais tarde.';
      } else if (errorMessage.contains('FormatException')) {
        return 'Erro de formatação de dados. Por favor, tente novamente.';
      } else if (errorMessage.contains('HttpException') || 
                errorMessage.contains('Connection closed') ||
                errorMessage.contains('Connection reset')) {
        return 'Erro na comunicação com o servidor. Tente novamente mais tarde.';
      } else if (errorMessage.contains('No host specified')) {
        return 'Erro de configuração. O endereço do servidor não está configurado corretamente.';
      } else if (errorMessage.contains('HandshakeException')) {
        return 'Erro de conexão segura. Verifique a data e hora do dispositivo.';
      }
      
      // Mensagem padrão para erros desconhecidos
      return 'Ocorreu um erro inesperado. Por favor, tente novamente.';
    } catch (e) {
      return 'Ocorreu um erro ao processar a mensagem de erro.';
    }
  }
  
  /// Exibe um snackbar de erro
  static void showErrorSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
      duration: duration,
      action: SnackBarAction(
        label: 'OK',
        textColor: Theme.of(context).colorScheme.onError,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

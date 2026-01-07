import 'package:flutter/material.dart';

class ErrorWidget extends StatelessWidget {
  final dynamic error;
  final StackTrace? stackTrace;
  final String? title;
  final String? message;
  final String retryButtonText;
  final VoidCallback? onRetry;
  final bool showStacktrace;
  final bool showRetryButton;
  final bool showIcon;

  const ErrorWidget({
    Key? key,
    required this.error,
    this.stackTrace,
    this.title,
    this.message,
    this.retryButtonText = 'Tentar novamente',
    this.onRetry,
    this.showStacktrace = false,
    this.showRetryButton = true,
    this.showIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final errorMessage = _getErrorMessage();
    final errorDetails = _getErrorDetails();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon) ...{
              Icon(
                Icons.error_outline,
                size: 64.0,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16.0),
            },
            
            Text(
              title ?? 'Ocorreu um erro',
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16.0),
            
            Text(
              errorMessage,
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            
            if (showStacktrace && errorDetails != null) ...{
              const SizedBox(height: 24.0),
              _buildErrorDetails(context, errorDetails),
            },
            
            if (showRetryButton && onRetry != null) ...{
              const SizedBox(height: 24.0),
              _buildRetryButton(context),
            },
          ],
        ),
      ),
    );
  }

  Widget _buildErrorDetails(BuildContext context, String details) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: theme.colorScheme.errorContainer.withOpacity(0.2)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          details,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onErrorContainer,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh, size: 20.0),
      label: Text(retryButtonText),
    );
  }

  String _getErrorMessage() {
    if (message != null) return message!;
    
    if (error is String) return error as String;
    
    // Mapeia mensagens de erro comuns para mensagens mais amigáveis
    final errorStr = error.toString();
    
    if (errorStr.contains('SocketException') || 
        errorStr.contains('Connection failed')) {
      return 'Sem conexão com a internet. Verifique sua conexão e tente novamente.';
    } else if (errorStr.contains('TimeoutException')) {
      return 'O servidor demorou muito para responder. Tente novamente mais tarde.';
    } else if (errorStr.contains('FormatException')) {
      return 'Erro de formatação de dados. Por favor, tente novamente.';
    } else if (errorStr.contains('HttpException')) {
      return 'Erro na comunicação com o servidor. Tente novamente mais tarde.';
    }
    
    // Mensagem padrão para erros desconhecidos
    return 'Ocorreu um erro inesperado. Por favor, tente novamente.';
  }

  String? _getErrorDetails() {
    if (error == null && stackTrace == null) return null;
    
    final buffer = StringBuffer();
    
    if (error != null) {
      buffer.writeln('Error: $error');
    }
    
    if (stackTrace != null) {
      buffer.writeln('\nStack trace:');
      buffer.writeln(stackTrace);
    }
    
    return buffer.toString();
  }

  static void showErrorDialog({
    required BuildContext context,
    required dynamic error,
    StackTrace? stackTrace,
    String? title,
    String? message,
    String? buttonText,
    VoidCallback? onPressed,
    bool showStacktrace = false,
    bool barrierDismissible = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Erro'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message ?? _getErrorMessageFromError(error)),
              if (showStacktrace && stackTrace != null) ...{
                const SizedBox(height: 16.0),
                Text(
                  'Detalhes: ${stackTrace.toString()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              },
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: onPressed ?? () => Navigator.of(context).pop(),
            child: Text(buttonText ?? 'OK'),
          ),
        ],
      ),
    );
  }

  static String _getErrorMessageFromError(dynamic error) {
    if (error is String) return error;
    
    final errorStr = error.toString();
    
    if (errorStr.contains('SocketException') || 
        errorStr.contains('Connection failed')) {
      return 'Sem conexão com a internet. Verifique sua conexão e tente novamente.';
    } else if (errorStr.contains('TimeoutException')) {
      return 'O servidor demorou muito para responder. Tente novamente mais tarde.';
    } else if (errorStr.contains('FormatException')) {
      return 'Erro de formatação de dados. Por favor, tente novamente.';
    } else if (errorStr.contains('HttpException')) {
      return 'Erro na comunicação com o servidor. Tente novamente mais tarde.';
    }
    
    return 'Ocorreu um erro inesperado. Por favor, tente novamente.';
  }
}

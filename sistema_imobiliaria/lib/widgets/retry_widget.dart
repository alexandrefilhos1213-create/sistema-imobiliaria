import 'package:flutter/material.dart';

class RetryWidget extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onRetry;
  final IconData? icon;
  final bool showIcon;
  final bool centerContent;
  final EdgeInsetsGeometry? padding;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final TextStyle? messageStyle;
  final ButtonStyle? buttonStyle;
  final bool fullWidthButton;

  const RetryWidget({
    Key? key,
    this.message = 'Não foi possível carregar os dados.',
    this.buttonText = 'Tentar novamente',
    required this.onRetry,
    this.icon,
    this.showIcon = true,
    this.centerContent = true,
    this.padding,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 16.0,
    this.messageStyle,
    this.buttonStyle,
    this.fullWidthButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        if (showIcon) ...{
          Icon(
            icon ?? Icons.refresh,
            size: 48.0,
            color: colorScheme.primary.withOpacity(0.5),
          ),
          SizedBox(height: spacing),
        },
        
        Text(
          message,
          style: messageStyle ?? textTheme.bodyLarge?.copyWith(
            color: textTheme.bodyLarge?.color?.withOpacity(0.7),
          ),
          textAlign: crossAxisAlignment == CrossAxisAlignment.center 
              ? TextAlign.center 
              : null,
        ),
        
        SizedBox(height: spacing),
        
        if (fullWidthButton)
          SizedBox(
            width: double.infinity,
            child: _buildRetryButton(context),
          )
        else
          _buildRetryButton(context),
      ],
    );

    if (centerContent) {
      return Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: padding ?? const EdgeInsets.all(24.0),
            child: content,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(24.0),
        child: content,
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    final theme = Theme.of(context);
    
    return ElevatedButton.icon(
      onPressed: onRetry,
      style: buttonStyle ?? ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      ),
      icon: const Icon(Icons.refresh, size: 20.0),
      label: Text(
        buttonText,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  static Widget withError({
    Key? key,
    required dynamic error,
    required VoidCallback onRetry,
    String? message,
    String? buttonText,
    bool showErrorDetails = false,
    bool centerContent = true,
  }) {
    return Builder(
      builder: (context) {
        String errorMessage = message ?? 'Ocorreu um erro ao carregar os dados.';
        
        if (showErrorDetails && error != null) {
          errorMessage += '\n\nDetalhes: ${error.toString()}';
        }
        
        return RetryWidget(
          key: key,
          message: errorMessage,
          onRetry: onRetry,
          buttonText: buttonText ?? 'Tentar novamente',
          icon: Icons.error_outline,
          centerContent: centerContent,
        );
      },
    );
  }

  static void showErrorDialog({
    required BuildContext context,
    required dynamic error,
    String? title,
    String? message,
    String? buttonText,
    VoidCallback? onRetry,
    bool showErrorDetails = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Erro'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message ?? 'Ocorreu um erro ao processar sua solicitação.'),
              if (showErrorDetails && error != null) ...{
                const SizedBox(height: 8.0),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              },
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: Text(buttonText ?? 'Tentar novamente'),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String message;
  final bool showMessage;
  final double size;
  final double strokeWidth;
  final Color? color;

  const LoadingWidget({
    Key? key,
    this.message = 'Carregando...',
    this.showMessage = true,
    this.size = 40.0,
    this.strokeWidth = 3.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? colorScheme.primary,
              ),
            ),
          ),
          if (showMessage) ...[
            const SizedBox(height: 16.0),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ButtonLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const ButtonLoadingIndicator({
    Key? key,
    this.size = 20.0,
    this.color,
    this.strokeWidth = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}

class FullScreenLoading extends StatelessWidget {
  final String message;
  final bool showMessage;
  final Color? backgroundColor;
  final bool barrierDismissible;
  final bool showBackground;

  const FullScreenLoading({
    Key? key,
    this.message = 'Carregando...',
    this.showMessage = true,
    this.backgroundColor,
    this.barrierDismissible = false,
    this.showBackground = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => barrierDismissible,
      child: Stack(
        children: [
          if (showBackground)
            ModalBarrier(
              dismissible: barrierDismissible,
              color: backgroundColor ?? Colors.black.withOpacity(0.5),
            ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: showBackground 
                    ? Theme.of(context).cardColor 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: showBackground
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10.0,
                          spreadRadius: 2.0,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (showMessage) ...[
                    const SizedBox(height: 16.0),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void show({
    required BuildContext context,
    String? message,
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => FullScreenLoading(
        message: message ?? 'Carregando...',
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

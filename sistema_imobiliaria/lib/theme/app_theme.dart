import 'package:flutter/material.dart';

class AppTheme {
  // Cores principais
  static const Color roseGoldStart = Color(0xFFE5A3A8);
  static const Color roseGoldEnd = Color(0xFFF6C7B6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color deepPurpleBlue = Color(0xFF3A2F8F);
  static const Color softPurple = Color(0xFF7C63E0);
  static const Color lightLavender = Color(0xFFB9A7FF);
  
  // Cores de apoio
  static const Color graphiteGray = Color(0xFF1E1E2A);
  static const Color bluishGray = Color(0xFF9093B0);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2B247A),
      Color(0xFF4938A8),
      Color(0xFF8D78FF),
    ],
  );
  
  static const LinearGradient roseGoldGradient = LinearGradient(
    colors: [
      roseGoldStart,
      roseGoldEnd,
    ],
  );
  
  // Tema principal
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepPurpleBlue,
      primaryColor: roseGoldStart,
      colorScheme: const ColorScheme.dark(
        primary: roseGoldStart,
        secondary: softPurple,
        surface: graphiteGray,
        background: deepPurpleBlue,
        onPrimary: white,
        onSecondary: white,
        onSurface: white,
        onBackground: white,
      ),
      
      // Tipografia
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: white,
          letterSpacing: 0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: white,
          letterSpacing: 0.3,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 28,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
          color: roseGoldStart,
          letterSpacing: 1.0,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Arial',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: white,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Arial',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: white,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Arial',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: bluishGray,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Arial',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: bluishGray,
        ),
      ),
      
      // Estilos de botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: roseGoldStart,
          foregroundColor: white,
          elevation: 8,
          shadowColor: roseGoldStart.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Cards
      cardTheme: CardThemeData(
        color: graphiteGray.withOpacity(0.3),
        elevation: 12,
        shadowColor: roseGoldStart.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: roseGoldStart.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      
      // Estilos de input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: graphiteGray.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: roseGoldStart.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: roseGoldStart.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: roseGoldStart,
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(
          color: bluishGray,
          fontFamily: 'Arial',
        ),
        hintStyle: TextStyle(
          color: bluishGray.withOpacity(0.6),
          fontFamily: 'Arial',
        ),
      ),
    );
  }
  
  // Glassmorphism container
  static Widget glassContainer({
    required Widget child,
    double borderRadius = 20,
    double opacity = 0.1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: roseGoldStart.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: roseGoldStart.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: white.withOpacity(opacity),
            border: Border.all(
              color: white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
  
  // Botão premium
  static Widget premiumButton({
    required String text,
    required VoidCallback onPressed,
    bool isGradient = true,
    double? width,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: isGradient ? roseGoldGradient : null,
        color: isGradient ? null : roseGoldStart,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: roseGoldStart.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

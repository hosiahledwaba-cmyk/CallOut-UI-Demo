// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'design_tokens.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: DesignTokens.accentPrimary,
      scaffoldBackgroundColor: Colors.transparent, // Handled by GlassScaffold
      fontFamily: 'SF Pro Display', // Fallback to system default if not present
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DesignTokens.accentPrimary,
        primary: DesignTokens.accentPrimary,
        secondary: DesignTokens.accentSecondary,
        error: DesignTokens.accentAlert,
        surface: Colors.transparent, // Important for glass UI
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: DesignTokens.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: DesignTokens.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          color: DesignTokens.textPrimary,
          height: 1.4,
        ),
        bodyMedium: TextStyle(fontSize: 15, color: DesignTokens.textSecondary),
      ),
      iconTheme: const IconThemeData(
        color: DesignTokens.textPrimary,
        size: DesignTokens.iconSizeMedium,
      ),
    );
  }
}

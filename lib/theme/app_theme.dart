// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'design_tokens.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: DesignTokens.accentPrimary,
      brightness: Brightness.light,
      primary: DesignTokens.accentPrimary,
      secondary: DesignTokens.accentSecondary,
      error: DesignTokens.accentAlert,
      surface: Colors.transparent,
    );

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: DesignTokens.accentPrimary,
      scaffoldBackgroundColor: Colors.transparent, // Handled by GlassScaffold
      fontFamily: 'SF Pro Display',
      useMaterial3: true,
      colorScheme: colorScheme,
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
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: DesignTokens.textPrimary),
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: DesignTokens.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: DesignTokens.accentPrimary,
      brightness: Brightness.dark,
      primary: DesignTokens.accentPrimary,
      secondary: DesignTokens.accentSecondary,
      error: DesignTokens.accentAlert,
      surface: Colors.transparent,
    );

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: DesignTokens.accentPrimary,
      scaffoldBackgroundColor:
          Colors.transparent, // GlassScaffold will handle visuals
      fontFamily: 'SF Pro Display',
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: DesignTokens.textPrimaryDark,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: DesignTokens.textPrimaryDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          color: DesignTokens.textPrimaryDark,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          color: DesignTokens.textSecondaryDark,
        ),
      ),
      iconTheme: const IconThemeData(
        color: DesignTokens.textPrimaryDark,
        size: DesignTokens.iconSizeMedium,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: DesignTokens.textPrimaryDark),
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: DesignTokens.textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

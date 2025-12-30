import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for SystemUiOverlayStyle
import 'design_tokens.dart';

class AppTheme {
  // ---------------------------------------------------------------------------
  // LIGHT THEME
  // ---------------------------------------------------------------------------
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: DesignTokens.accentPrimary,
      scaffoldBackgroundColor: DesignTokens.backgroundTop, // Fallback color
      // Font Definition
      fontFamily: 'SF Pro Display',
      useMaterial3: true,

      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: DesignTokens.accentPrimary,
        brightness: Brightness.light,
        surface: DesignTokens.glassWhite,
        onSurface: DesignTokens.textPrimary,
      ),

      // AppBar: Transparent with Dark Icons
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: DesignTokens.textPrimary),
        titleTextStyle: TextStyle(
          color: DesignTokens.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'SF Pro Display',
        ),
        // Force Status Bar to be Dark Icons
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light, // iOS
        ),
      ),

      // Text Theme
      textTheme: _buildTextTheme(
        DesignTokens.textPrimary,
        DesignTokens.textSecondary,
      ),

      // Component: Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return DesignTokens.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected))
            return DesignTokens.accentPrimary;
          return Colors.transparent;
        }),
        trackOutlineColor: WidgetStateProperty.all(DesignTokens.textSecondary),
      ),

      // Component: ListTile
      listTileTheme: const ListTileThemeData(
        textColor: DesignTokens.textPrimary,
        iconColor: DesignTokens.textPrimary,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DARK THEME
  // ---------------------------------------------------------------------------
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: DesignTokens.accentPrimary,
      scaffoldBackgroundColor: DesignTokens.backgroundTopDark, // Fallback

      fontFamily: 'SF Pro Display',
      useMaterial3: true,

      // Color Scheme: Key for ensuring widgets default to dark mode colors
      colorScheme: ColorScheme.fromSeed(
        seedColor: DesignTokens.accentPrimary,
        brightness: Brightness.dark,
        surface: DesignTokens.glassDark, // Cards will use this color
        onSurface: DesignTokens.textPrimaryDark, // Text will use this
      ),

      // AppBar: Transparent with Light Icons
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: DesignTokens.textPrimaryDark),
        titleTextStyle: TextStyle(
          color: DesignTokens.textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'SF Pro Display',
        ),
        // Force Status Bar to be Light Icons (White)
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark, // iOS
        ),
      ),

      // Text Theme
      textTheme: _buildTextTheme(
        DesignTokens.textPrimaryDark,
        DesignTokens.textSecondaryDark,
      ),

      // Component: Icons
      iconTheme: const IconThemeData(color: DesignTokens.textPrimaryDark),

      // Component: Switch (Customized for Dark Mode)
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected))
            return DesignTokens.accentPrimary;
          return DesignTokens.textSecondaryDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected))
            return DesignTokens.accentPrimary.withOpacity(0.3);
          return DesignTokens.glassDark;
        }),
        trackOutlineColor: WidgetStateProperty.all(
          DesignTokens.textSecondaryDark,
        ),
      ),

      // Component: ListTile
      listTileTheme: const ListTileThemeData(
        textColor: DesignTokens.textPrimaryDark,
        iconColor: DesignTokens.textPrimaryDark,
      ),
    );
  }

  // Helper to keep text styling consistent
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primary,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      bodyLarge: TextStyle(fontSize: 17, color: primary, height: 1.4),
      bodyMedium: TextStyle(fontSize: 15, color: secondary),
    );
  }
}

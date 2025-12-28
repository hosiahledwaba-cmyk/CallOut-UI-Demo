// lib/theme/design_tokens.dart
import 'package:flutter/material.dart';

class DesignTokens {
  // Light Colors - Pastels & Glass
  static const Color backgroundTop = Color(0xFFE0EAFC);
  static const Color backgroundBottom = Color(0xFFCFDEF3);

  static const Color accentPrimary = Color(0xFF8E2DE2); // Deep Purple
  static const Color accentSecondary = Color(0xFF4A00E0); // Violet
  static const Color accentAlert = Color(0xFFFF5F6D); // Soft Red for SOS
  static const Color accentSafe = Color(0xFF00B09B); // Teal for verified

  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textLight = Color(0xFFFFFFFF);

  static const Color glassWhite = Color(0xFFFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF); // 20% White
  static const Color glassShadow = Color(0x1A2D3436); // 10% Dark

  // Dark-mode tokens
  static const Color backgroundTopDark = Color(0xFF0F1724);
  static const Color backgroundBottomDark = Color(0xFF071226);

  static const Color textPrimaryDark = Color(0xFFEFF3F7); // near-white for text
  static const Color textSecondaryDark = Color(0xFFB9C2C9);

  static const Color glassDark = Color(0xFF12131A);
  static const Color glassBorderDark = Color(
    0x33FFFFFF,
  ); // slightly visible border
  static const Color glassShadowDark = Color(0x26000000);

  // Metrics
  static const double borderRadiusSmall = 12.0;
  static const double borderRadiusMedium = 20.0;
  static const double borderRadiusLarge = 32.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double blurSigma = 18.0;
  static const double blurSigmaReduced = 0.0;

  static const double iconSizeSmall = 18.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // Animation
  static const Duration durationFast = Duration(milliseconds: 220);
  static const Duration durationMedium = Duration(milliseconds: 360);
  static const Curve animationCurve = Curves.easeOutCubic;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentSecondary, accentPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient alertGradient = LinearGradient(
    colors: [Color(0xFFFFC371), Color(0xFFFF5F6D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

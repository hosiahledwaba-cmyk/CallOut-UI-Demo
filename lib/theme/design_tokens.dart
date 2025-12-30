import 'package:flutter/material.dart';

class DesignTokens {
  // ===========================================================================
  // 1. GLOBAL PRIMITIVES
  // ===========================================================================

  // Brand Colors
  static const Color accentPrimary = Color(0xFF8E2DE2); // Deep Purple
  static const Color accentSecondary = Color(0xFF4A00E0); // Violet
  static const Color accentAlert = Color(0xFFFF5F6D); // Soft Red for SOS
  static const Color accentSafe = Color(0xFF00B09B); // Teal for verified

  // ===========================================================================
  // 2. LIGHT THEME TOKENS
  // ===========================================================================
  static const Color backgroundTop = Color(0xFFE0EAFC);
  static const Color backgroundBottom = Color(0xFFCFDEF3);

  static const Color textPrimary = Color(0xFF2D3436); // Dark Grey
  static const Color textSecondary = Color(0xFF636E72); // Medium Grey

  // Glass Effect (Light)
  static const Color glassWhite = Color(0xCCFFFFFF); // 80% White
  static const Color glassBorder = Color(0x4DFFFFFF); // 30% White border
  static const Color glassShadow = Color(0x1A2D3436); // 10% Dark shadow

  // ===========================================================================
  // 3. DARK THEME TOKENS (PREMIUM DARK)
  // ===========================================================================
  // Richer, deeper blues for a "Midnight" feel
  static const Color backgroundTopDark = Color(0xFF0F172A); // Slate 900
  static const Color backgroundBottomDark = Color(0xFF020617); // Slate 950

  static const Color textPrimaryDark = Color(
    0xFFF8FAFC,
  ); // Slate 50 (Crisp White)
  static const Color textSecondaryDark = Color(
    0xFF94A3B8,
  ); // Slate 400 (Soft Grey)

  // Glass Effect (Dark) - "Black Glass"
  // Instead of white glass, we use dark glass with a light border
  static const Color glassDark = Color(0xB31E293B); // 70% Dark Slate
  static const Color glassBorderDark = Color(
    0x1AFFFFFF,
  ); // 10% White border (Subtle)
  static const Color glassShadowDark = Color(0x80000000); // 50% Black shadow

  // ===========================================================================
  // 4. COMMON METRICS
  // ===========================================================================
  static const double borderRadiusSmall = 12.0;
  static const double borderRadiusMedium = 20.0;
  static const double borderRadiusLarge = 32.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double iconSizeSmall = 18.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentSecondary, accentPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const double blurSigma = 16.0;
  static const double blurSigmaReduced = 0.0;
  // Animation
  static const Duration durationFast = Duration(milliseconds: 220);
  static const Duration durationMedium = Duration(milliseconds: 360);
  static const Curve animationCurve = Curves.easeOutCubic;
}

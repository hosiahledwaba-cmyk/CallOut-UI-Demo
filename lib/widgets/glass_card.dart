// lib/widgets/glass_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../app_settings.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool isAlert;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.width,
    this.height,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsProvider.of(context);
    final reduceTransparency = settings?.reduceTransparency ?? false;
    final blurSigma = reduceTransparency ? 0.0 : DesignTokens.blurSigma;

    // Check if we are in Dark Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 1. DETERMINE COLORS
    Color baseColor;
    Color borderColor;
    Color shadowColor;

    if (isAlert) {
      // SOS / Alert Card Styling
      baseColor = DesignTokens.accentAlert.withOpacity(
        reduceTransparency ? 1.0 : 0.15,
      );
      borderColor = DesignTokens.accentAlert.withOpacity(0.5);
      shadowColor = DesignTokens.accentAlert.withOpacity(0.2);
    } else {
      // Standard Card Styling
      if (isDark) {
        // Dark Mode: "Smoked Glass" (Dark Grey/Blue)
        baseColor = reduceTransparency
            ? const Color(0xFF1E293B) // Solid dark if no transparency
            : DesignTokens.glassDark;

        borderColor = DesignTokens.glassBorderDark;
        shadowColor = DesignTokens.glassShadowDark;
      } else {
        // Light Mode: "Frosted Glass" (White)
        baseColor = reduceTransparency
            ? Colors.white
            : DesignTokens.glassWhite.withOpacity(
                0.60,
              ); // Slightly more transparent for frost effect

        borderColor = DesignTokens.glassBorder;
        shadowColor = DesignTokens.glassShadow;
      }
    }

    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.all(0),
      // ClipRRect needed to contain the BackdropFilter blur
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.borderRadiusMedium),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Material(
            color:
                Colors.transparent, // Material must be transparent to show blur
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(
                DesignTokens.borderRadiusMedium,
              ),
              // Subtle highlight colors based on theme
              highlightColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : DesignTokens.glassWhite.withOpacity(0.2),
              splashColor: isDark
                  ? Colors.white.withOpacity(0.1)
                  : DesignTokens.glassWhite.withOpacity(0.3),
              child: Container(
                padding:
                    padding ?? const EdgeInsets.all(DesignTokens.paddingMedium),
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(
                    DesignTokens.borderRadiusMedium,
                  ),
                  border: Border.all(color: borderColor, width: 1.0),
                  boxShadow: reduceTransparency
                      ? [] // No shadow if transparency reduced (flatter look)
                      : [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

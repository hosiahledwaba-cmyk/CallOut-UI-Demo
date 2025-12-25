// lib/widgets/glass_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../app.dart';

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

    // Background color logic based on accessibility
    final baseColor = isAlert
        ? DesignTokens.accentAlert.withOpacity(reduceTransparency ? 1.0 : 0.1)
        : DesignTokens.glassWhite.withOpacity(reduceTransparency ? 0.9 : 0.45);

    final borderColor = isAlert
        ? DesignTokens.accentAlert.withOpacity(0.5)
        : DesignTokens.glassBorder;

    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.all(0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.borderRadiusMedium),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: InkWell(
            onTap: onTap,
            highlightColor: DesignTokens.glassWhite.withOpacity(0.1),
            splashColor: DesignTokens.glassWhite.withOpacity(0.2),
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
                    ? []
                    : [
                        BoxShadow(
                          color: DesignTokens.glassShadow,
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
    );
  }
}

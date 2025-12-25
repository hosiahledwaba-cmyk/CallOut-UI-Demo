// lib/widgets/glass_button.dart
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final IconData? icon;

  const GlassButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isPrimary = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isPrimary ? DesignTokens.primaryGradient : null,
        color: isPrimary ? null : DesignTokens.glassWhite.withOpacity(0.3),
        borderRadius: BorderRadius.circular(DesignTokens.borderRadiusLarge),
        boxShadow: [
          if (isPrimary)
            BoxShadow(
              color: DesignTokens.accentPrimary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignTokens.borderRadiusLarge),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: DesignTokens.paddingMedium,
              horizontal: DesignTokens.paddingLarge,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: isPrimary ? Colors.white : DesignTokens.textPrimary,
                    size: DesignTokens.iconSizeSmall,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: isPrimary ? Colors.white : DesignTokens.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

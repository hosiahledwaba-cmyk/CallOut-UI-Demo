// lib/widgets/resource_carousel_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/resource.dart';
import '../theme/design_tokens.dart';
import 'glass_card.dart';

class ResourceCarouselCard extends StatelessWidget {
  final Resource resource;
  final VoidCallback? onTap;

  const ResourceCarouselCard({super.key, required this.resource, this.onTap});

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(resource.category);
    // 1. Check Theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? DesignTokens.textPrimaryDark
        : DesignTokens.textPrimary;
    final secondaryTextColor = isDark
        ? DesignTokens.textSecondaryDark
        : DesignTokens.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- HEADER ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(resource.category),
                    color: catColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: primaryTextColor, // Dynamic Color
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            resource.distance,
                            style: TextStyle(
                              color: secondaryTextColor, // Dynamic Color
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "•",
                            style: TextStyle(color: secondaryTextColor),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            resource.isOpenNow ? 'Open Now' : 'Closed',
                            style: TextStyle(
                              color: resource.isOpenNow
                                  ? DesignTokens.accentSafe
                                  : DesignTokens.accentAlert,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // --- DESCRIPTION ---
            Flexible(
              child: Text(
                resource.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: secondaryTextColor, // Dynamic Color
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ),

            const SizedBox(height: 12),
            Divider(
              color: isDark
                  ? DesignTokens.glassBorderDark.withOpacity(0.5)
                  : DesignTokens.glassBorder.withOpacity(0.5),
              height: 1,
            ),
            const SizedBox(height: 12),

            // --- ACTION BUTTONS ROW ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _CircularActionButton(
                  icon: CupertinoIcons.phone_fill,
                  label: "Call",
                  gradient: DesignTokens.primaryGradient,
                  iconColor: Colors.white,
                  onTap: () {},
                  isDark: isDark,
                ),
                _CircularActionButton(
                  icon: CupertinoIcons.location_fill,
                  label: "Route",
                  iconColor: DesignTokens.accentSecondary,
                  onTap: () {},
                  isDark: isDark,
                ),
                _CircularActionButton(
                  icon: CupertinoIcons.share,
                  label: "Share",
                  iconColor: secondaryTextColor,
                  onTap: () {},
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ... (Icons and Color methods remain same) ...
  IconData _getCategoryIcon(ResourceCategory category) {
    switch (category) {
      case ResourceCategory.police:
        return Icons.local_police;
      case ResourceCategory.medical:
        return CupertinoIcons.heart_fill;
      case ResourceCategory.shelter:
        return CupertinoIcons.house_fill;
      case ResourceCategory.legal:
        return CupertinoIcons.briefcase_fill;
      case ResourceCategory.counseling:
        return CupertinoIcons.chat_bubble_2_fill;
      default:
        return CupertinoIcons.info;
    }
  }

  Color _getCategoryColor(ResourceCategory category) {
    switch (category) {
      case ResourceCategory.police:
        return Colors.blueAccent;
      case ResourceCategory.medical:
        return DesignTokens.accentAlert;
      case ResourceCategory.shelter:
        return DesignTokens.accentPrimary;
      case ResourceCategory.legal:
        return Colors.indigo;
      default:
        return DesignTokens.accentSecondary;
    }
  }
}

class _CircularActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;
  final Gradient? gradient;
  final bool isDark; // Added param

  const _CircularActionButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
    this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = gradient != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: gradient,
                color: isPrimary
                    ? null
                    : (isDark
                          ? DesignTokens.glassDark
                          : DesignTokens.glassWhite.withOpacity(0.4)),
                border: isPrimary
                    ? null
                    : Border.all(
                        color: isDark
                            ? DesignTokens.glassBorderDark
                            : DesignTokens.glassBorder,
                      ),
                boxShadow: isPrimary
                    ? [
                        BoxShadow(
                          color: DesignTokens.accentPrimary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(child: Icon(icon, color: iconColor, size: 22)),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? DesignTokens.textSecondaryDark
                : DesignTokens.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

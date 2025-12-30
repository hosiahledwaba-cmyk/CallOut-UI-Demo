// lib/widgets/resource_detail_sheet.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/resource.dart';
import '../theme/design_tokens.dart';
import 'glass_button.dart';

class ResourceDetailSheet extends StatelessWidget {
  final Resource resource;

  const ResourceDetailSheet({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    // 1. Check Theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? DesignTokens.textPrimaryDark
        : DesignTokens.textPrimary;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              decoration: BoxDecoration(
                // 2. Swap Background
                color: isDark
                    ? DesignTokens.glassDark.withOpacity(0.9)
                    : DesignTokens.glassWhite.withOpacity(0.85),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                border: Border(
                  top: BorderSide(
                    color: isDark ? DesignTokens.glassBorderDark : Colors.white,
                    width: 1.0,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: DesignTokens.accentPrimary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconForCategory(resource.category),
                          color: DesignTokens.accentPrimary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resource.name,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: textColor, // Dynamic
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${resource.distance} away • ${_getCategoryString(resource.category)}",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: isDark
                                        ? DesignTokens.textSecondaryDark
                                        : DesignTokens.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Status Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: resource.isOpenNow
                          ? DesignTokens.accentSafe.withOpacity(0.1)
                          : DesignTokens.accentAlert.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          resource.isOpenNow
                              ? Icons.check_circle
                              : Icons.access_time,
                          size: 16,
                          color: resource.isOpenNow
                              ? DesignTokens.accentSafe
                              : DesignTokens.accentAlert,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          resource.isOpenNow ? "Open Now" : "Closed",
                          style: TextStyle(
                            color: resource.isOpenNow
                                ? DesignTokens.accentSafe
                                : DesignTokens.accentAlert,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    "About",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: textColor, // Dynamic
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    resource.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: textColor, // Dynamic
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          label: "Call Now",
                          icon: CupertinoIcons.phone_fill,
                          isPrimary: true,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GlassButton(
                          label: "Directions",
                          icon: CupertinoIcons.location_fill,
                          isPrimary: false,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GlassButton(
                    label: "Share Location",
                    icon: CupertinoIcons.share,
                    isPrimary: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getCategoryString(ResourceCategory cat) {
    return cat.name[0].toUpperCase() + cat.name.substring(1);
  }

  IconData _getIconForCategory(ResourceCategory cat) {
    switch (cat) {
      case ResourceCategory.police:
        return Icons.local_police;
      case ResourceCategory.medical:
        return Icons.local_hospital;
      case ResourceCategory.shelter:
        return Icons.home;
      case ResourceCategory.legal:
        return Icons.gavel;
      default:
        return Icons.place;
    }
  }
}

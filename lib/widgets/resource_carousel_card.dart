// lib/widgets/resource_carousel_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/resource.dart';
import '../theme/design_tokens.dart';
import 'glass_card.dart';
import 'glass_button.dart';

class ResourceCarouselCard extends StatelessWidget {
  final Resource resource;
  final VoidCallback? onTap;

  const ResourceCarouselCard({super.key, required this.resource, this.onTap});

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

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(resource.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(resource.category),
                    color: catColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${resource.distance} • ${resource.isOpenNow ? 'Open Now' : 'Closed'}",
                        style: TextStyle(
                          color: resource.isOpenNow
                              ? DesignTokens.accentSafe
                              : DesignTokens.accentAlert,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              resource.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: DesignTokens.textSecondary,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: GlassButton(
                      label: "Call",
                      icon: CupertinoIcons.phone_fill,
                      isPrimary: true,
                      onTap: () {
                        // TODO: launchUrl("tel:${resource.phoneNumber}")
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: GlassButton(
                      label: "Route",
                      icon: CupertinoIcons.location_fill,
                      isPrimary: false,
                      onTap: () {
                        // TODO: Launch maps
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

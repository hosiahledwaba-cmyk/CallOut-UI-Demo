// lib/widgets/top_nav.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/design_tokens.dart';
import '../screens/notifications_screen.dart';
import '../screens/settings_screen.dart';

class TopNav extends StatelessWidget {
  final String title;
  final bool showBack;
  final bool showSettings;
  final bool showNotificationIcon;
  final List<Widget>? extraActions;

  const TopNav({
    super.key,
    required this.title,
    this.showBack = false,
    this.showSettings = false,
    this.showNotificationIcon = true,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        // Floating margin (sides and top)
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.paddingMedium,
          vertical: 8,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32), // Fully rounded pill shape
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Strong blur
            child: Container(
              height: 60, // Fixed compact height
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                // Highly translucent white for frosted effect
                color: DesignTokens.glassWhite.withOpacity(0.5),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: DesignTokens.glassBorder, width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.glassShadow.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // --- Left Section (Back or Settings) ---
                  SizedBox(width: 40, child: _buildLeading(context)),

                  // --- Center Section (Title) ---
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  // --- Right Section (Actions + Notify) ---
                  SizedBox(
                    width: null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (extraActions != null) ...extraActions!,

                        if (showNotificationIcon) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationsScreen(),
                              ),
                            ),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: DesignTokens.glassWhite.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    CupertinoIcons.bell,
                                    size: 20,
                                    color: DesignTokens.textPrimary,
                                  ),
                                  // Red Dot Indicator
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: DesignTokens.accentAlert,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else if (extraActions == null) ...[
                          // Spacer to balance the title if no icons on right
                          const SizedBox(width: 40),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (showBack) {
      return GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          alignment: Alignment.centerLeft,
          color: Colors.transparent, // Hitbox expansion
          child: const Icon(
            CupertinoIcons.back,
            color: DesignTokens.textPrimary,
          ),
        ),
      );
    }

    if (showSettings || !showBack) {
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        ),
        child: Container(
          alignment: Alignment.centerLeft,
          color: Colors.transparent, // Hitbox expansion
          child: const Icon(
            CupertinoIcons.settings,
            color: DesignTokens.textPrimary,
          ),
        ),
      );
    }

    return null;
  }
}

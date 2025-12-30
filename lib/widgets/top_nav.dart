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
    // 1. Check Theme
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.paddingMedium,
          vertical: 8,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                // 2. Swap Background
                color: isDark
                    ? DesignTokens.glassDark
                    : DesignTokens.glassWhite.withOpacity(0.5),
                borderRadius: BorderRadius.circular(32),
                // 3. Swap Border
                border: Border.all(
                  color: isDark
                      ? DesignTokens.glassBorderDark
                      : DesignTokens.glassBorder,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? DesignTokens.glassShadowDark
                        : DesignTokens.glassShadow.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // --- Left Section ---
                  SizedBox(width: 40, child: _buildLeading(context, isDark)),

                  // --- Center Section ---
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        // 4. Swap Text Color
                        color: isDark
                            ? DesignTokens.textPrimaryDark
                            : DesignTokens.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  // --- Right Section ---
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
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : DesignTokens.glassWhite.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.bell,
                                    size: 20,
                                    color: isDark
                                        ? DesignTokens.textPrimaryDark
                                        : DesignTokens.textPrimary,
                                  ),
                                  // Red Dot
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

  Widget? _buildLeading(BuildContext context, bool isDark) {
    final iconColor = isDark
        ? DesignTokens.textPrimaryDark
        : DesignTokens.textPrimary;

    if (showBack) {
      return GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          alignment: Alignment.centerLeft,
          color: Colors.transparent,
          child: Icon(CupertinoIcons.back, color: iconColor),
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
          color: Colors.transparent,
          child: Icon(CupertinoIcons.settings, color: iconColor),
        ),
      );
    }

    return null;
  }
}

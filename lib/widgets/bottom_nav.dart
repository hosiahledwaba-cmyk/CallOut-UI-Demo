// lib/widgets/bottom_nav.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../theme/design_tokens.dart';
import '../screens/feed_screen.dart';
import '../screens/search_screen.dart';
import '../screens/messages_list_screen.dart';
import '../screens/profile_screen.dart';
import '../state/notification_state.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;

  const BottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const FeedScreen();
        break;
      case 1:
        nextScreen = const SearchScreen();
        break;
      case 2:
        nextScreen = const MessagesListScreen();
        break;
      case 3:
        nextScreen = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<NotificationState>().unreadCount;
    // 1. Check Theme
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.paddingMedium,
        0,
        DesignTokens.paddingMedium,
        DesignTokens.paddingMedium + 10,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              // 2. Swap Background Color
              color: isDark
                  ? DesignTokens.glassDark
                  : DesignTokens.glassWhite.withOpacity(0.65),
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
                      : DesignTokens.glassShadow.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: CupertinoIcons.home,
                  isActive: currentIndex == 0,
                  onTap: () => _onTap(context, 0),
                  isDark: isDark, // Pass theme down
                ),
                _NavItem(
                  icon: CupertinoIcons.search,
                  isActive: currentIndex == 1,
                  onTap: () => _onTap(context, 1),
                  isDark: isDark,
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _NavItem(
                      icon: CupertinoIcons.chat_bubble,
                      isActive: currentIndex == 2,
                      onTap: () => _onTap(context, 2),
                      isDark: isDark,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: 10,
                        right: 12,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: DesignTokens.accentAlert,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                _NavItem(
                  icon: CupertinoIcons.person,
                  isActive: currentIndex == 3,
                  onTap: () => _onTap(context, 3),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;

  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: AnimatedScale(
          scale: isActive ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Icon(
            icon,
            size: 28,
            // 4. Swap Icon Color (Active is always Primary, Inactive changes based on theme)
            color: isActive
                ? DesignTokens.accentPrimary
                : (isDark
                      ? DesignTokens.textSecondaryDark
                      : DesignTokens.textSecondary),
          ),
        ),
      ),
    );
  }
}

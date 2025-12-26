// lib/widgets/bottom_nav.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/design_tokens.dart';
import '../screens/feed_screen.dart';
import '../screens/search_screen.dart';
import '../screens/messages_list_screen.dart';
import '../screens/profile_screen.dart';

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
    return Padding(
      // Padding creates the "Floating" effect, lifting it off the edges
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.paddingMedium,
        0,
        DesignTokens.paddingMedium,
        DesignTokens.paddingMedium +
            10, // Extra bottom padding for iPhone home indicator area
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32), // Fully rounded pill shape
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 70, // Compact height
            decoration: BoxDecoration(
              color: DesignTokens.glassWhite.withOpacity(0.65),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: DesignTokens.glassBorder, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.glassShadow.withOpacity(0.15),
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
                ),
                _NavItem(
                  icon: CupertinoIcons.search,
                  isActive: currentIndex == 1,
                  onTap: () => _onTap(context, 1),
                ),
                _NavItem(
                  icon: CupertinoIcons.chat_bubble,
                  isActive: currentIndex == 2,
                  onTap: () => _onTap(context, 2),
                ),
                _NavItem(
                  icon: CupertinoIcons.person,
                  isActive: currentIndex == 3,
                  onTap: () => _onTap(context, 3),
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

  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // Ensures tap target size is decent
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: AnimatedScale(
          scale: isActive ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Icon(
            icon,
            size: 28,
            color: isActive
                ? DesignTokens.accentPrimary
                : DesignTokens.textSecondary,
          ),
        ),
      ),
    );
  }
}

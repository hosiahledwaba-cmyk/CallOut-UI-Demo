// lib/widgets/glass_scaffold.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_tokens.dart';
import 'bottom_nav.dart';

class GlassScaffold extends StatelessWidget {
  final Widget body;
  final int currentTabIndex;
  final Widget? floatingActionButton;
  final bool showBottomNav;

  const GlassScaffold({
    super.key,
    required this.body,
    this.currentTabIndex = -1,
    this.floatingActionButton,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context) {
    // Theme check
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topColor = isDark
        ? DesignTokens.backgroundTopDark
        : DesignTokens.backgroundTop;
    final bottomColor = isDark
        ? DesignTokens.backgroundBottomDark
        : DesignTokens.backgroundBottom;

    // Status Bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: topColor,
      extendBody: true,
      extendBodyBehindAppBar: true,
      // Note: We REMOVED floatingActionButton from here to handle it manually in the Stack
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [topColor, bottomColor],
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(bottom: false, child: body),

          // 3. Custom Bottom Nav
          if (showBottomNav && currentTabIndex != -1)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNav(currentIndex: currentTabIndex),
            ),

          // 4. FLOATING ACTION BUTTON (Manual Position)
          // We place it at bottom: 110 to sit nicely ABOVE the glass nav (which is ~80px tall)
          if (floatingActionButton != null)
            Positioned(
              bottom: 110,
              right: DesignTokens.paddingMedium,
              child: floatingActionButton!,
            ),
        ],
      ),
    );
  }
}

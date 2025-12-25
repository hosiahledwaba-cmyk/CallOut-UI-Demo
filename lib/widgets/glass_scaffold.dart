// lib/widgets/glass_scaffold.dart
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import 'bottom_nav.dart';

class GlassScaffold extends StatelessWidget {
  final Widget body;
  final Widget? floatingActionButton;
  final int currentTabIndex;
  final bool showBottomNav;

  const GlassScaffold({
    super.key,
    required this.body,
    this.floatingActionButton,
    this.currentTabIndex = -1,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Important for glass bottom bar
      floatingActionButton: floatingActionButton,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.5, -0.6),
            radius: 1.2,
            colors: [
              DesignTokens.backgroundTop,
              DesignTokens.backgroundBottom,
              Color(0xFFE6E6FA), // Lavender hint
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Ambient Orbs (Visual depth)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DesignTokens.accentPrimary.withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: DesignTokens.accentPrimary.withOpacity(0.2),
                      blurRadius: 100,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(bottom: false, child: body),
          ],
        ),
      ),
      bottomNavigationBar: showBottomNav
          ? BottomNav(currentIndex: currentTabIndex)
          : null,
    );
  }
}

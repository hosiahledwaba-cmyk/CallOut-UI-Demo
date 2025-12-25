// lib/widgets/top_nav.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/design_tokens.dart';
import '../screens/notifications_screen.dart';
import '../screens/settings_screen.dart';

class TopNav extends StatelessWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;

  const TopNav({
    super.key,
    required this.title,
    this.showBack = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBack)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(CupertinoIcons.back),
            )
          else
            // Settings Icon on left if home
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              child: const Icon(CupertinoIcons.settings),
            ),

          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignTokens.textPrimary,
            ),
          ),

          if (actions != null)
            Row(children: actions!)
          else
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
              child: const Icon(CupertinoIcons.bell),
            ),
        ],
      ),
    );
  }
}

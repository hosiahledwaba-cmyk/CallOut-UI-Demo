// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/glass_card.dart';
import '../theme/design_tokens.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      showBottomNav: false,
      body: Column(
        children: [
          const TopNav(title: "Notifications", showBack: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(DesignTokens.paddingMedium),
              children: [
                _buildNotificationItem(
                  "Safety Alert: Protest near City Center.",
                  true,
                ),
                _buildNotificationItem("Sarah liked your post.", false),
                _buildNotificationItem(
                  "New resources added to your area.",
                  false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String text, bool isUrgent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GlassCard(
        isAlert: isUrgent,
        child: ListTile(
          leading: Icon(
            isUrgent ? Icons.warning : Icons.info_outline,
            color: isUrgent
                ? DesignTokens.accentAlert
                : DesignTokens.accentPrimary,
          ),
          title: Text(text),
          trailing: const Text(
            "Just now",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

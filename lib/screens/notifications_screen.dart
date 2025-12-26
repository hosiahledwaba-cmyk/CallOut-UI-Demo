// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/glass_card.dart';
import '../theme/design_tokens.dart';
import '../data/notification_repository.dart';
import '../models/notification_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationRepository _repository = NotificationRepository();
  late Future<List<NotificationItem>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _repository.getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      showBottomNav: false,
      body: Column(
        children: [
          const TopNav(title: "Notifications", showBack: true),
          Expanded(
            child: FutureBuilder<List<NotificationItem>>(
              future: _notificationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.all(DesignTokens.paddingMedium),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _buildNotificationItem(items[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GlassCard(
        isAlert: item.isUrgent,
        child: ListTile(
          leading: Icon(
            item.isUrgent ? Icons.warning : Icons.info_outline,
            color: item.isUrgent
                ? DesignTokens.accentAlert
                : DesignTokens.accentPrimary,
          ),
          title: Text(item.message),
          trailing: const Text(
            "Just now",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

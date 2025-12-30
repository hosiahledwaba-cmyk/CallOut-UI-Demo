// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/glass_card.dart';
import '../widgets/avatar.dart';
import '../theme/design_tokens.dart';
import '../state/notification_state.dart';
import '../models/notification_item.dart';
import '../utils/time_formatter.dart';
import 'post_detail_screen.dart';
import 'profile_screen.dart';
import '../data/feed_repository.dart'; // To fetch post for navigation

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationState>().refresh();
    });
  }

  void _handleTap(NotificationItem item) async {
    // 1. Mark as read immediately
    context.read<NotificationState>().markRead(item.id);

    // 2. Navigate based on type
    if (item.type == NotificationType.follow) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileScreen(userId: item.sender.id),
        ),
      );
    } else if ((item.type == NotificationType.like ||
            item.type == NotificationType.comment ||
            item.type == NotificationType.repost) &&
        item.referenceId != null) {
      // Fetch post and navigate (Basic implementation)
      // In a real app, you might want a specialized loading state here
      final post = await FeedRepository().getPostById(item.referenceId!);
      if (post != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NotificationState>();
    final items = state.items;

    return GlassScaffold(
      showBottomNav: false,
      body: Column(
        children: [
          TopNav(
            title: "Notifications",
            showBack: true,
            extraActions: [
              IconButton(
                icon: const Icon(
                  Icons.done_all,
                  color: DesignTokens.textSecondary,
                ),
                tooltip: "Mark all read",
                onPressed: () =>
                    context.read<NotificationState>().markAllRead(),
              ),
            ],
          ),
          Expanded(
            child: state.isLoading && items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async => state.refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(DesignTokens.paddingMedium),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationItem(items[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 48,
            color: DesignTokens.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            "No notifications yet",
            style: TextStyle(color: DesignTokens.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: () => _handleTap(item),
        child: GlassCard(
          // Highlight unread items with a slight tint or border?
          // For Glass UI, maybe we just use a bold font or a dot indicator.
          // Here we use a subtly different background opacity if read/unread (handled by GlassCard styling usually,
          // but let's add a visual cue).
          child: Container(
            color: item.isRead
                ? Colors.transparent
                : DesignTokens.accentPrimary.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Avatar
                  Avatar(user: item.sender, radius: 24),

                  const SizedBox(width: 12),

                  // 2. Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: DesignTokens.textPrimary,
                              fontSize: 14,
                              fontFamily: 'Roboto', // Or your default font
                            ),
                            children: [
                              TextSpan(
                                text: item.sender.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: _getActionText(item)),
                            ],
                          ),
                        ),
                        if (item.referenceText != null &&
                            item.referenceText!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '"${item.referenceText}"',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: DesignTokens.textSecondary,
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          TimeFormatter.formatRelative(item.createdAt),
                          style: TextStyle(
                            color: item.isRead
                                ? DesignTokens.textSecondary
                                : DesignTokens.accentPrimary,
                            fontSize: 12,
                            fontWeight: item.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Icon Indicator
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8),
                    child: _getIconForType(item.type),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getActionText(NotificationItem item) {
    switch (item.type) {
      case NotificationType.like:
        return " liked your post.";
      case NotificationType.comment:
        return " commented: ";
      case NotificationType.follow:
        return " started following you.";
      case NotificationType.repost:
        return " reposted your post.";
      case NotificationType.mention:
        return " mentioned you.";
      case NotificationType.message:
        return " sent a message.";
      default:
        return " sent a notification.";
    }
  }

  Widget _getIconForType(NotificationType type) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.like:
        icon = Icons.favorite;
        color = DesignTokens.accentAlert; // Red heart
        break;
      case NotificationType.comment:
        icon = Icons.chat_bubble;
        color = DesignTokens.accentSafe; // Blue/Green
        break;
      case NotificationType.follow:
        icon = Icons.person_add;
        color = DesignTokens.accentPrimary; // Purple
        break;
      case NotificationType.repost:
        icon = Icons.repeat;
        color = DesignTokens.textSecondary;
        break;
      default:
        icon = Icons.notifications;
        color = DesignTokens.textSecondary;
    }

    return Icon(icon, size: 20, color: color);
  }
}

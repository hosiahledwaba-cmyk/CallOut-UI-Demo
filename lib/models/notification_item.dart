// lib/models/notification_item.dart
import 'user.dart';

enum NotificationType {
  like,
  comment,
  follow,
  repost,
  mention,
  message,
  unknown,
}

class NotificationItem {
  final String id;
  final User sender;
  final NotificationType type;
  final String? referenceId; // Post ID or User ID
  final String? referenceText;
  final bool isRead;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.sender,
    required this.type,
    this.referenceId,
    this.referenceText,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      // Safely parse sender, fallback to dummy if missing
      sender: json['sender'] != null
          ? User.fromJson(json['sender'])
          : const User(
              id: 'unknown',
              username: 'Unknown',
              displayName: 'Unknown',
              avatarUrl: '',
            ),
      type: _parseType(json['type']),
      referenceId: json['reference_id'],
      referenceText: json['reference_text'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static NotificationType _parseType(String? type) {
    switch (type) {
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'follow':
        return NotificationType.follow;
      case 'repost':
        return NotificationType.repost;
      case 'message':
        return NotificationType.message;
      default:
        return NotificationType.unknown;
    }
  }
}

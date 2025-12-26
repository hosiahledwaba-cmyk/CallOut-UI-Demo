// lib/models/notification_item.dart
class NotificationItem {
  final String id;
  final String message;
  final bool isUrgent;
  final DateTime timestamp;

  const NotificationItem({
    required this.id,
    required this.message,
    required this.isUrgent,
    required this.timestamp,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      message: json['message'] ?? '',
      isUrgent: json['is_urgent'] ?? false,
      timestamp: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

// lib/utils/time_formatter.dart
import 'package:intl/intl.dart'; // Add "intl: ^0.19.0" to pubspec.yaml if missing

class TimeFormatter {
  /// Returns "2h ago", "5m ago", "Just now", or "10 Oct"
  static String formatRelative(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return DateFormat('d MMM').format(timestamp);
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Returns simple time: "14:30"
  static String formatTime(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp);
  }

  /// Returns friendly chat time: "Today, 14:30" or "Yesterday, 09:00"
  static String formatChatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    final timeStr = DateFormat('HH:mm').format(timestamp);

    if (dateToCheck == today) {
      return "Today, $timeStr";
    } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
      return "Yesterday, $timeStr";
    } else {
      return DateFormat('d MMM, HH:mm').format(timestamp);
    }
  }
}

// lib/utils/time_formatter.dart
import 'package:intl/intl.dart'; // Add intl: ^0.18.1 to pubspec.yaml

class TimeFormatter {
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  static String formatChatTime(DateTime date) {
    return DateFormat('HH:mm').format(date); // 14:30
  }
}

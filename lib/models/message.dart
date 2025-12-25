// lib/models/message.dart
import 'user.dart';

class Message {
  final String id;
  final User sender;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  const Message({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });
}

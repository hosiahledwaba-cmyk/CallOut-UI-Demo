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

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      sender: User.fromJson(json['sender'] ?? {}),
      text: json['text'] ?? '',
      // CRITICAL UPDATE: Safe parsing for Server Timestamps
      // We use tryParse to prevent crashes if the server sends a malformed string
      // or if the field is temporarily missing during a latency compensation write.
      timestamp: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.toJson(),
      'text': text,
      'created_at': timestamp.toIso8601String(),
      'is_read': isRead,
    };
  }

  // Necessary for optimistic updates (updating list before API returns)
  Message copyWith({
    String? id,
    User? sender,
    String? text,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

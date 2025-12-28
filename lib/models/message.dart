// lib/models/message.dart
import 'user.dart';

class Message {
  final String id;
  final User sender;
  final String text;
  final String? mediaId; // New Field for Chat Media
  final DateTime timestamp;
  final bool isRead;

  const Message({
    required this.id,
    required this.sender,
    required this.text,
    this.mediaId,
    required this.timestamp,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      sender: User.fromJson(json['sender'] ?? {}),
      text: json['text'] ?? '',
      // Map the media_id from backend
      mediaId: json['media_id'],
      // Safe Timestamp Parsing
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
      'media_id': mediaId,
      'created_at': timestamp.toIso8601String(),
      'is_read': isRead,
    };
  }

  Message copyWith({
    String? id,
    User? sender,
    String? text,
    String? mediaId,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      mediaId: mediaId ?? this.mediaId,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

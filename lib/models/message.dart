// lib/models/message.dart
import 'user.dart';
import 'post.dart';
import '../utils/merge_utils.dart'; // Import MergeUtils

// 1. Implement Identifiable
class Message implements Identifiable {
  @override
  final String id;
  final User sender;
  final String text;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;

  final String? mediaId;
  final Post? sharedPost;

  const Message({
    required this.id,
    required this.sender,
    required this.text,
    this.type = MessageType.text,
    required this.timestamp,
    this.isRead = false,
    this.mediaId,
    this.sharedPost,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      sender: User.fromJson(json['sender'] ?? {}),
      text: json['text'] ?? '',
      type: _parseType(json['type']),
      timestamp: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
      mediaId: json['media_id'],
      sharedPost: json['shared_post'] != null
          ? Post.fromJson(json['shared_post'])
          : null,
    );
  }

  static MessageType _parseType(String? type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'post':
        return MessageType.post;
      default:
        return MessageType.text;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.toJson(),
      'text': text,
      'type': type.name,
      'media_id': mediaId,
      'shared_post': sharedPost?.toJson(),
      'created_at': timestamp.toIso8601String(),
      'is_read': isRead,
    };
  }
}

enum MessageType { text, image, post }

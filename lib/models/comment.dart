// lib/models/comment.dart
import 'user.dart';

class Comment {
  final String id;
  final User author;
  final String text;
  final DateTime timestamp;

  const Comment({
    required this.id,
    required this.author,
    required this.text,
    required this.timestamp,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      author: User.fromJson(json['author'] ?? {}),
      text: json['text'] ?? '',
      timestamp: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author.toJson(),
    'text': text,
    'created_at': timestamp.toIso8601String(),
  };

  // Added copyWith for consistency
  Comment copyWith({
    String? id,
    User? author,
    String? text,
    DateTime? timestamp,
  }) {
    return Comment(
      id: id ?? this.id,
      author: author ?? this.author,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

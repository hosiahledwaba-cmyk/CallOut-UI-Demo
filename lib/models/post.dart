// lib/models/post.dart
import 'user.dart';

class Post {
  final String id;
  final User author;
  final String content;
  final String? imageUrl;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final bool isEmergency;

  const Post({
    required this.id,
    required this.author,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.isEmergency = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      author: User.fromJson(json['author'] ?? {}),
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      timestamp: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      likes: json['likes_count'] ?? 0,
      comments: json['comments_count'] ?? 0,
      isEmergency: json['is_emergency'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.toJson(),
      'content': content,
      'image_url': imageUrl,
      'created_at': timestamp.toIso8601String(),
      'likes_count': likes,
      'comments_count': comments,
      'is_emergency': isEmergency,
    };
  }
}

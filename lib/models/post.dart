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
  final bool isLiked; // New field

  const Post({
    required this.id,
    required this.author,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.isEmergency = false,
    this.isLiked = false, // Default to false
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
      isLiked: json['is_liked'] ?? false,
    );
  }

  // CopyWith for optimistic updates
  Post copyWith({int? likes, bool? isLiked, int? comments}) {
    return Post(
      id: id,
      author: author,
      content: content,
      imageUrl: imageUrl,
      timestamp: timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isEmergency: isEmergency,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

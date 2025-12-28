import 'user.dart';

class Post {
  final String id;
  final User author;
  final String content;
  final String? imageUrl;
  final DateTime timestamp; // Mapped from 'created_at'
  final int likes;
  final int comments;
  final bool isLiked;
  final bool isEmergency;

  const Post({
    required this.id,
    required this.author,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    this.isEmergency = false,
  });

  Post copyWith({
    String? id,
    User? author,
    String? content,
    String? imageUrl,
    DateTime? timestamp,
    int? likes,
    int? comments,
    bool? isLiked,
    bool? isEmergency,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      isEmergency: isEmergency ?? this.isEmergency,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      author: User.fromJson(json['author'] ?? {}),
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      // CRITICAL: Safe parsing for timestamp
      timestamp: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      likes: json['likes_count'] ?? 0,
      comments: json['comments_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isEmergency: json['is_emergency'] ?? false,
    );
  }
}

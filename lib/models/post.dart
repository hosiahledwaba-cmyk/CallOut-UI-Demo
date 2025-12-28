// lib/models/post.dart
import 'user.dart';

class Post {
  final String id;
  final User author;
  final String content;
  final String? imageUrl; // Legacy/External URL support
  final List<String> mediaIds; // MEDIA STRATEGY: List of internal media IDs
  final DateTime timestamp;
  final int likes;
  final int comments;
  final bool isLiked;
  final bool isEmergency;

  const Post({
    required this.id,
    required this.author,
    required this.content,
    this.imageUrl,
    this.mediaIds = const [], // Default empty
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
    List<String>? mediaIds,
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
      mediaIds: mediaIds ?? this.mediaIds,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      isEmergency: isEmergency ?? this.isEmergency,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    // DEBUG: Check if media_ids are arriving
    if (json['media_ids'] != null && (json['media_ids'] as List).isNotEmpty) {
      print("📦 Post ${json['id']} has media: ${json['media_ids']}");
    }

    return Post(
      id: json['id'] ?? '',
      author: User.fromJson(json['author'] ?? {}),
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      // Ensure this mapping matches the backend key
      mediaIds: List<String>.from(json['media_ids'] ?? []),
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

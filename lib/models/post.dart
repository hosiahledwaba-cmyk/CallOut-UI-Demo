// lib/models/post.dart
import 'user.dart';
import '../utils/merge_utils.dart';

class Post implements Identifiable {
  @override
  final String id;
  final User author;
  final String content;
  final String? imageUrl;
  final List<String> mediaIds;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final bool isEmergency;

  // REPOST FIELDS
  final Post? repostedPost;
  final bool isRepost;

  const Post({
    required this.id,
    required this.author,
    required this.content,
    this.imageUrl,
    this.mediaIds = const [],
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLiked = false,
    this.isEmergency = false,
    this.repostedPost,
    this.isRepost = false,
  });

  // ... copyWith (kept same as before) ...
  Post copyWith({
    String? id,
    User? author,
    String? content,
    String? imageUrl,
    List<String>? mediaIds,
    DateTime? timestamp,
    int? likes,
    int? comments,
    int? shares,
    bool? isLiked,
    bool? isEmergency,
    Post? repostedPost,
    bool? isRepost,
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
      shares: shares ?? this.shares,
      isLiked: isLiked ?? this.isLiked,
      isEmergency: isEmergency ?? this.isEmergency,
      repostedPost: repostedPost ?? this.repostedPost,
      isRepost: isRepost ?? this.isRepost,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      author: User.fromJson(json['author'] ?? {}),
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      mediaIds: List<String>.from(json['media_ids'] ?? []),
      timestamp: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      likes: json['likes_count'] ?? 0,
      comments: json['comments_count'] ?? 0,
      shares: json['shares_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isEmergency: json['is_emergency'] ?? false,
      isRepost: json['is_repost'] ?? false,
      // Recursive parsing for the inner post
      repostedPost: json['reposted_post'] != null
          ? Post.fromJson(json['reposted_post'])
          : null,
    );
  }

  // NEW: Serialization for API usage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'image_url': imageUrl,
      'media_ids': mediaIds,
      'created_at': timestamp.toIso8601String(),
      'is_repost': isRepost,
      if (repostedPost != null) 'repost_of_id': repostedPost!.id,
    };
  }
}

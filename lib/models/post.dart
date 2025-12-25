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
}

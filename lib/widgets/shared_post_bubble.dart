// lib/widgets/shared_post_bubble.dart
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../theme/design_tokens.dart';
import 'cached_base64_image.dart';
import 'avatar.dart';
import '../screens/post_detail_screen.dart';

class SharedPostBubble extends StatelessWidget {
  final Post post;
  final bool isMe;

  const SharedPostBubble({super.key, required this.post, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the full post when tapped
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
        );
      },
      child: Container(
        width: 240, // Fixed width for consistent look
        decoration: BoxDecoration(
          // Slightly darker/lighter inner container to distinguish from bubble bg
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Author Header
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Avatar(user: post.author, radius: 10),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      post.author.displayName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Media Preview (if any)
            if (post.mediaIds.isNotEmpty)
              SizedBox(
                height: 140,
                width: double.infinity,
                child: CachedBase64Image(
                  mediaId: post.mediaIds.first,
                  fit: BoxFit.cover,
                ),
              )
            else if (post.imageUrl != null)
              SizedBox(
                height: 140,
                width: double.infinity,
                child: Image.network(
                  post.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey),
                ),
              ),

            // 3. Content Snippet
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

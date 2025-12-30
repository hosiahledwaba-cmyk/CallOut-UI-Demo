// lib/widgets/live_post_widgets.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/auth_service.dart';
import '../data/feed_repository.dart';
import '../theme/design_tokens.dart';

// --- WIDGET 1: LIVE LIKE BUTTON ---
class LiveLikeButton extends StatelessWidget {
  final String postId;
  final bool initialIsLiked;
  final Color activeColor;
  final Color inactiveColor;

  const LiveLikeButton({
    super.key,
    required this.postId,
    required this.initialIsLiked,
    this.activeColor = DesignTokens.accentAlert,
    this.inactiveColor = DesignTokens.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final userId = AuthService().currentUser?.id;

    if (userId == null) {
      return _buildIcon(initialIsLiked, context);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId) // <--- CHANGED from .document() to .doc()
          .collection('likes')
          .doc(userId) // <--- CHANGED from .document() to .doc()
          .snapshots(),
      builder: (context, snapshot) {
        final bool isLiked = snapshot.hasData && snapshot.data!.exists
            ? true
            : (snapshot.connectionState == ConnectionState.waiting
                  ? initialIsLiked
                  : false);

        return GestureDetector(
          onTap: () async {
            await FeedRepository().likePost(postId, !isLiked);
          },
          child: _buildIcon(isLiked, context),
        );
      },
    );
  }

  Widget _buildIcon(bool isLiked, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.transparent,
      child: AnimatedScale(
        scale: isLiked ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Icon(
          isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          color: isLiked ? activeColor : inactiveColor,
          size: 24,
        ),
      ),
    );
  }
}

// --- WIDGET 2: LIVE STATS (Likes & Comments Count) ---
class LivePostStats extends StatelessWidget {
  final String postId;
  final int initialLikes;
  final int initialComments;
  final Color textColor;

  const LivePostStats({
    super.key,
    required this.postId,
    required this.initialLikes,
    required this.initialComments,
    this.textColor = DesignTokens.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId) // <--- CHANGED from .document() to .doc()
          .snapshots(),
      builder: (context, snapshot) {
        int likes = initialLikes;
        int comments = initialComments;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          likes = data['likes_count'] ?? initialLikes;
          comments = data['comments_count'] ?? initialComments;
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStat(likes, "Likes"),
            const SizedBox(width: 16),
            _buildStat(comments, "Comments"),
          ],
        );
      },
    );
  }

  Widget _buildStat(int count, String label) {
    return Text(
      "$count $label",
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }
}

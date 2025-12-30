// lib/widgets/live_interactions.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/auth_service.dart';
import '../data/feed_repository.dart';
import '../theme/design_tokens.dart';

// --- SHARED UI: Matches your _InteractionButton exactly ---
class LiveInteractionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const LiveInteractionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = DesignTokens.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

// --- LIVE LIKE BUTTON ---
// Handles both the Like Count (from Post) and Red/Grey Heart (from Subcollection)
class LiveLikeButton extends StatefulWidget {
  final String postId;
  final int initialLikes;
  final bool initialIsLiked;

  const LiveLikeButton({
    super.key,
    required this.postId,
    required this.initialLikes,
    required this.initialIsLiked,
  });

  @override
  State<LiveLikeButton> createState() => _LiveLikeButtonState();
}

class _LiveLikeButtonState extends State<LiveLikeButton> {
  bool? _optimisticLike; // Immediate UI feedback

  @override
  Widget build(BuildContext context) {
    final userId = AuthService().currentUser?.id;

    // 1. Stream: Post Document (For accurate Likes Count)
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .snapshots(),
      builder: (context, postSnap) {
        int likeCount = widget.initialLikes;
        if (postSnap.hasData && postSnap.data!.exists) {
          likeCount =
              (postSnap.data!.data() as Map<String, dynamic>)['likes_count'] ??
              widget.initialLikes;
        }

        // 2. Stream: Like Status (Red or Grey)
        return StreamBuilder<DocumentSnapshot>(
          stream: userId != null
              ? FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.postId)
                    .collection('likes')
                    .doc(userId)
                    .snapshots()
              : null,
          builder: (context, likeSnap) {
            // LOGIC: Determine if liked
            bool isLiked = widget.initialIsLiked;

            if (_optimisticLike != null) {
              isLiked = _optimisticLike!; // Priority 1: User just tapped
            } else if (likeSnap.hasData && likeSnap.data!.exists) {
              isLiked = true; // Priority 2: Database says liked
            } else if (likeSnap.hasData && !likeSnap.data!.exists) {
              isLiked = false; // Priority 3: Database says NOT liked
            }

            return LiveInteractionButton(
              icon: isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              label: "$likeCount",
              color: isLiked
                  ? DesignTokens.accentAlert
                  : DesignTokens.textSecondary,
              onTap: () {
                if (userId == null) return;

                // Optimistic Update
                setState(() => _optimisticLike = !isLiked);

                // API Call (using your correct repo method)
                FeedRepository().likePost(widget.postId, !isLiked).then((_) {
                  if (mounted) setState(() => _optimisticLike = null);
                });
              },
            );
          },
        );
      },
    );
  }
}

// --- LIVE COMMENT BUTTON ---
// Handles the Comment Count updating in real-time
class LiveCommentButton extends StatelessWidget {
  final String postId;
  final int initialComments;
  final VoidCallback onTap;

  const LiveCommentButton({
    super.key,
    required this.postId,
    required this.initialComments,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .snapshots(),
      builder: (context, snapshot) {
        int commentCount = initialComments;
        if (snapshot.hasData && snapshot.data!.exists) {
          commentCount =
              (snapshot.data!.data()
                  as Map<String, dynamic>)['comments_count'] ??
              initialComments;
        }

        return LiveInteractionButton(
          icon: CupertinoIcons.chat_bubble,
          label: "$commentCount",
          onTap: onTap,
        );
      },
    );
  }
}

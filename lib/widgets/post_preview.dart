// lib/widgets/post_preview.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/post.dart';
import 'glass_card.dart';
import 'avatar.dart';
import 'cached_base64_image.dart';
import 'share_bottom_sheet.dart'; // Import the new Share Sheet
import '../theme/design_tokens.dart';
import '../screens/post_detail_screen.dart';
import '../screens/profile_screen.dart';
import '../data/feed_repository.dart';
import '../utils/time_formatter.dart';

class PostPreview extends StatefulWidget {
  final Post post;

  const PostPreview({super.key, required this.post});

  @override
  State<PostPreview> createState() => _PostPreviewState();
}

class _PostPreviewState extends State<PostPreview> {
  late Post _post; // The wrapper post (may be a repost)
  late Post _displayPost; // The actual content to show

  final FeedRepository _repo = FeedRepository();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializePostData();
  }

  // Helper to set up the post vs display post logic
  void _initializePostData() {
    _post = widget.post;
    // If this is a repost and has inner content, display the inner content.
    // Otherwise, display the post itself.
    _displayPost = (_post.isRepost && _post.repostedPost != null)
        ? _post.repostedPost!
        : _post;
  }

  // --- CRITICAL FIX START ---
  @override
  void didUpdateWidget(PostPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent (FeedScreen) passes a new Post object (from background poll),
    // update local state immediately.
    if (widget.post != oldWidget.post) {
      setState(() {
        _initializePostData();
      });
    }
  }
  // --- CRITICAL FIX END ---

  void _handleLike() {
    // We like the CONTENT post (the one being displayed)
    final wasLiked = _displayPost.isLiked;

    setState(() {
      // Optimistically update the display post
      _displayPost = _displayPost.copyWith(
        isLiked: !wasLiked,
        likes: _displayPost.likes + (wasLiked ? -1 : 1),
      );

      // If it wasn't a repost, we also update the wrapper for consistency
      if (!_post.isRepost) {
        _post = _displayPost;
      }
    });

    _repo.likePost(_displayPost.id, !wasLiked);
  }

  void _handleShare() {
    // Open the new robust Share Sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ShareBottomSheet(post: _displayPost),
    );
  }

  void _navigateToProfile() {
    // Navigate to the author of the CONTENT (not the reposter)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userId: _displayPost.author.id),
      ),
    );
  }

  void _handleTap() async {
    final updatedPost = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(post: _displayPost),
      ),
    );

    if (updatedPost != null && updatedPost is Post && mounted) {
      setState(() {
        // If we returned from detail with an updated object, sync it back
        if (_post.isRepost) {
          // If it was a repost, we only update the inner content
          // (Creating a new wrapper would require a more complex copyWith,
          // usually simpler just to rely on the background poller)
          // But for immediate feedback, we can update _displayPost locally.
          _displayPost = updatedPost;
        } else {
          _post = updatedPost;
          _displayPost = updatedPost;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. REPOST HEADER (Only if it is a repost)
          if (_post.isRepost)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.repeat,
                    size: 14,
                    color: DesignTokens.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "${_post.author.displayName} reposted",
                    style: const TextStyle(
                      color: DesignTokens.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // 2. MAIN CARD
          GlassCard(
            isAlert: _displayPost.isEmergency,
            onTap: _handleTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                GestureDetector(
                  onTap: _navigateToProfile,
                  child: Row(
                    children: [
                      Avatar(user: _displayPost.author),
                      const SizedBox(width: DesignTokens.paddingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _displayPost.author.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (_displayPost.author.isVerified) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified,
                                    size: 14,
                                    color: DesignTokens.accentSafe,
                                  ),
                                ],
                                const SizedBox(width: 8),
                                Text(
                                  "• ${TimeFormatter.formatRelative(_displayPost.timestamp)}",
                                  style: const TextStyle(
                                    color: DesignTokens.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "@${_displayPost.author.username}",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      if (_displayPost.isEmergency)
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: DesignTokens.accentAlert,
                        ),
                    ],
                  ),
                ),

                // Content
                const SizedBox(height: DesignTokens.paddingMedium),
                Text(
                  _displayPost.content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                // MEDIA RENDERING
                if (_displayPost.mediaIds.isNotEmpty) ...[
                  const SizedBox(height: DesignTokens.paddingMedium),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      DesignTokens.borderRadiusSmall,
                    ),
                    child: SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: PageView.builder(
                        itemCount: _displayPost.mediaIds.length,
                        onPageChanged: (index) =>
                            setState(() => _currentImageIndex = index),
                        itemBuilder: (context, index) {
                          return CachedBase64Image(
                            mediaId: _displayPost.mediaIds[index],
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.contain,
                          );
                        },
                      ),
                    ),
                  ),
                  // Dots Indicator
                  if (_displayPost.mediaIds.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _displayPost.mediaIds.length > 5
                              ? 5
                              : _displayPost.mediaIds.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index
                                  ? DesignTokens.accentPrimary
                                  : DesignTokens.textSecondary.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                ] else if (_displayPost.imageUrl != null &&
                    _displayPost.imageUrl!.isNotEmpty) ...[
                  // Fallback for legacy
                  const SizedBox(height: DesignTokens.paddingMedium),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      DesignTokens.borderRadiusSmall,
                    ),
                    child: Image.network(
                      _displayPost.imageUrl!,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const SizedBox(),
                    ),
                  ),
                ],

                // Actions
                const SizedBox(height: DesignTokens.paddingMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InteractionButton(
                      icon: _displayPost.isLiked
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      color: _displayPost.isLiked
                          ? DesignTokens.accentAlert
                          : DesignTokens.textSecondary,
                      label: "${_displayPost.likes}",
                      onTap: _handleLike,
                    ),
                    _InteractionButton(
                      icon: CupertinoIcons.chat_bubble,
                      label: "${_displayPost.comments}",
                      onTap: _handleTap,
                    ),
                    _InteractionButton(
                      icon: CupertinoIcons.share,
                      label: "Share",
                      onTap: _handleShare, // Triggers the Share Sheet
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _InteractionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = DesignTokens.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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

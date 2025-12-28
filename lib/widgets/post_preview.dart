// lib/widgets/post_preview.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/post.dart';
import 'glass_card.dart';
import 'avatar.dart';
import 'cached_base64_image.dart'; // Ensure this file exists in lib/widgets/
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
  late Post _post;
  final FeedRepository _repo = FeedRepository();

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  void _handleLike() {
    final wasLiked = _post.isLiked;
    setState(() {
      _post = _post.copyWith(
        isLiked: !wasLiked,
        likes: _post.likes + (wasLiked ? -1 : 1),
      );
    });
    _repo.likePost(_post.id, !wasLiked);
  }

  void _handleShare() {
    _repo.sharePost(_post.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Post shared to clipboard!"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userId: _post.author.id),
      ),
    );
  }

  void _handleTap() async {
    final updatedPost = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostDetailScreen(post: _post)),
    );

    if (updatedPost != null && updatedPost is Post && mounted) {
      setState(() {
        _post = updatedPost;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.paddingMedium),
      child: GlassCard(
        isAlert: _post.isEmergency,
        onTap: _handleTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            GestureDetector(
              onTap: _navigateToProfile,
              child: Row(
                children: [
                  Avatar(user: _post.author),
                  const SizedBox(width: DesignTokens.paddingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _post.author.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (_post.author.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 14,
                                color: DesignTokens.accentSafe,
                              ),
                            ],
                            const SizedBox(width: 8),
                            // AUDIT: Relative Timestamp
                            Text(
                              "• ${TimeFormatter.formatRelative(_post.timestamp)}",
                              style: const TextStyle(
                                color: DesignTokens.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "@${_post.author.username}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (_post.isEmergency)
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: DesignTokens.accentAlert,
                    ),
                ],
              ),
            ),

            // Content Text
            const SizedBox(height: DesignTokens.paddingMedium),
            Text(_post.content, style: Theme.of(context).textTheme.bodyLarge),

            // MEDIA RENDERING
            // Priority 1: Check for Database Media (mediaIds)
            if (_post.mediaIds.isNotEmpty) ...[
              const SizedBox(height: DesignTokens.paddingMedium),
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  DesignTokens.borderRadiusSmall,
                ),
                child: SizedBox(
                  height: 200, // FORCE HEIGHT
                  width: double.infinity, // FORCE WIDTH
                  child: CachedBase64Image(
                    mediaId: _post.mediaIds.first,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ]
            // Priority 2: Check for Legacy/External URL
            else if (_post.imageUrl != null && _post.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: DesignTokens.paddingMedium),
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  DesignTokens.borderRadiusSmall,
                ),
                child: Image.network(
                  _post.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const SizedBox(),
                ),
              ),
            ],

            // Interaction Buttons
            const SizedBox(height: DesignTokens.paddingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InteractionButton(
                  icon: _post.isLiked
                      ? CupertinoIcons.heart_fill
                      : CupertinoIcons.heart,
                  color: _post.isLiked
                      ? DesignTokens.accentAlert
                      : DesignTokens.textSecondary,
                  label: "${_post.likes}",
                  onTap: _handleLike,
                ),
                _InteractionButton(
                  icon: CupertinoIcons.chat_bubble,
                  label: "${_post.comments}",
                  onTap: _handleTap,
                ),
                _InteractionButton(
                  icon: CupertinoIcons.share,
                  label: "Share",
                  onTap: _handleShare,
                ),
              ],
            ),
          ],
        ),
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

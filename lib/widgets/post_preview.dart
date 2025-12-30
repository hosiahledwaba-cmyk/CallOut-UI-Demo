// lib/widgets/post_preview.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/post.dart';
import 'glass_card.dart';
import 'avatar.dart';
import 'cached_base64_image.dart';
import 'share_bottom_sheet.dart';
import '../theme/design_tokens.dart';
import '../screens/post_detail_screen.dart';
import '../screens/profile_screen.dart';
import '../data/feed_repository.dart';
import '../utils/time_formatter.dart';
import 'live_interactions.dart'; // <--- IMPORT THIS

class PostPreview extends StatefulWidget {
  final Post post;

  const PostPreview({super.key, required this.post});

  @override
  State<PostPreview> createState() => _PostPreviewState();
}

class _PostPreviewState extends State<PostPreview> {
  late Post _post;
  late Post _displayPost;

  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializePostData();
  }

  void _initializePostData() {
    _post = widget.post;
    _displayPost = (_post.isRepost && _post.repostedPost != null)
        ? _post.repostedPost!
        : _post;
  }

  @override
  void didUpdateWidget(PostPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.post != oldWidget.post) {
      setState(() {
        _initializePostData();
      });
    }
  }

  void _handleShare() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ShareBottomSheet(post: _displayPost),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userId: _displayPost.author.id),
      ),
    );
  }

  void _handleTap() async {
    // When returning from details, we don't strictly need to setState
    // because the Live Widgets handle the sync now!
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(post: _displayPost),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. REPOST HEADER
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
                                Flexible(
                                  child: Text(
                                    _displayPost.author.displayName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
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

                // Media Carousel
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
                    ),
                  ),
                ],

                // --- ACTIONS FOOTER (LIVE UPDATES) ---
                const SizedBox(height: DesignTokens.paddingMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1. LIVE LIKE
                    LiveLikeButton(
                      postId: _displayPost.id,
                      initialLikes: _displayPost.likes,
                      initialIsLiked: _displayPost.isLiked,
                    ),

                    // 2. LIVE COMMENTS
                    LiveCommentButton(
                      postId: _displayPost.id,
                      initialComments: _displayPost.comments,
                      onTap: _handleTap,
                    ),

                    // 3. STATIC SHARE (No live counter needed usually)
                    LiveInteractionButton(
                      icon: CupertinoIcons.share,
                      label: "Share",
                      onTap: _handleShare,
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

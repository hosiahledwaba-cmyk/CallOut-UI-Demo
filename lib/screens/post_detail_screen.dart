// lib/screens/post_detail_screen.dart
import 'dart:async'; // Import for Timer
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../models/post.dart';
import '../models/comment.dart';
import '../data/feed_repository.dart';
import '../state/app_state_notifier.dart'; // Import App State
import '../utils/merge_utils.dart'; // Import MergeUtils
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/avatar.dart';
import '../widgets/glass_card.dart';
import '../widgets/cached_base64_image.dart';
import '../theme/design_tokens.dart';
import 'profile_screen.dart';
import '../utils/time_formatter.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final FeedRepository _repository = FeedRepository();
  final TextEditingController _commentController = TextEditingController();

  // Local state for comments
  List<Comment> _comments = [];
  Timer? _commentTimer;
  bool _isFetchingComments = false;

  // Used for carousel in main view
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initial fetch
    _fetchComments(force: true);
    // Start Polling for new comments every 3s
    _startCommentPolling();
  }

  @override
  void dispose() {
    _commentTimer?.cancel(); // Stop polling when screen closes
    _commentController.dispose();
    super.dispose();
  }

  // --- POLLING LOGIC START ---
  void _startCommentPolling() {
    _commentTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _fetchComments();
    });
  }

  Future<void> _fetchComments({bool force = false}) async {
    if (_isFetchingComments && !force) return;
    if (!mounted) return;

    _isFetchingComments = true;

    try {
      final incomingComments = await _repository.getComments(widget.post.id);

      // If we have no comments and fetched none, stop here
      if (incomingComments.isEmpty && _comments.isEmpty) {
        if (mounted) setState(() {});
        return;
      }

      // SMART MERGE: This prevents the list from jumping/flashing
      final mergedComments = MergeUtils.mergeLists<Comment>(
        current: _comments,
        incoming: incomingComments,
        prependNew: true, // New comments appear at the top
      );

      if (mounted) {
        setState(() {
          _comments = mergedComments;
        });
      }
    } catch (e) {
      print("Comment fetch failed: $e");
    } finally {
      _isFetchingComments = false;
    }
  }
  // --- POLLING LOGIC END ---

  void _handleSubmitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    _commentController.clear();

    final newComment = await _repository.addComment(widget.post.id, text);

    if (newComment != null && mounted) {
      setState(() {
        _comments.insert(0, newComment);
      });
      // Force immediate refresh to sync
      _fetchComments(force: true);
    }
  }

  void _navigateToProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen(userId: userId)),
    );
  }

  void _openMediaViewer(Post livePost, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PostMediaViewer(post: livePost, initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Theme Checks
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? DesignTokens.textPrimaryDark
        : DesignTokens.textPrimary;
    final secondaryTextColor = isDark
        ? DesignTokens.textSecondaryDark
        : DesignTokens.textSecondary;
    final inputBgColor = isDark
        ? DesignTokens.glassDark
        : DesignTokens.glassWhite.withOpacity(0.65);
    final inputBorderColor = isDark
        ? DesignTokens.glassBorderDark
        : DesignTokens.glassBorder;

    // 1. WATCH GLOBAL STATE FOR LIKES
    final livePost = context.select<AppStateNotifier, Post>((notifier) {
      try {
        return notifier.feed.firstWhere((p) => p.id == widget.post.id);
      } catch (e) {
        return widget.post; // Fallback if post not in global feed
      }
    });

    return GlassScaffold(
      showBottomNav: false,
      body: Stack(
        children: [
          Column(
            children: [
              const TopNav(title: "Post", showBack: true),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(DesignTokens.paddingMedium),
                  child: Column(
                    children: [
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Author Header
                            GestureDetector(
                              onTap: () =>
                                  _navigateToProfile(livePost.author.id),
                              child: Row(
                                children: [
                                  Avatar(user: livePost.author, radius: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          livePost.author.displayName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: primaryTextColor, // Dynamic
                                          ),
                                        ),
                                        Text(
                                          "@${livePost.author.username}",
                                          style: TextStyle(
                                            color:
                                                secondaryTextColor, // Dynamic
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Post Content Text
                            Text(
                              livePost.content,
                              style: TextStyle(
                                fontSize: 18,
                                height: 1.5,
                                color: primaryTextColor, // Dynamic
                              ),
                            ),

                            // --- MEDIA CAROUSEL ---
                            if (livePost.mediaIds.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  height: 400,
                                  width: double.infinity,
                                  child: PageView.builder(
                                    itemCount: livePost.mediaIds.length,
                                    onPageChanged: (index) {
                                      setState(
                                        () => _currentImageIndex = index,
                                      );
                                    },
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () =>
                                            _openMediaViewer(livePost, index),
                                        child: Hero(
                                          tag:
                                              'post_media_${livePost.id}_$index',
                                          child: CachedBase64Image(
                                            mediaId: livePost.mediaIds[index],
                                            fit: BoxFit.contain,
                                            height: 400,
                                            width: double.infinity,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Dots Indicator
                              if (livePost.mediaIds.length > 1)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      livePost.mediaIds.length,
                                      (index) => Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                        ),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _currentImageIndex == index
                                              ? DesignTokens.accentPrimary
                                              : (isDark
                                                    ? DesignTokens
                                                          .glassBorderDark
                                                    : DesignTokens.glassBorder),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ] else if (livePost.imageUrl != null &&
                                livePost.imageUrl!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () => _openMediaViewer(livePost, 0),
                                child: Hero(
                                  tag: 'post_img_${livePost.id}',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      livePost.imageUrl!,
                                      height: 400,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),
                            Divider(
                              color: isDark
                                  ? DesignTokens.glassBorderDark
                                  : DesignTokens.glassBorder,
                            ),
                            // Stats Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${livePost.likes} Likes",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: secondaryTextColor, // Dynamic
                                  ),
                                ),
                                // Use local list length for accurate count
                                Text(
                                  "Comments (${_comments.length})",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: secondaryTextColor, // Dynamic
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      // Comments List
                      if (_comments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              "No comments yet.",
                              style: TextStyle(
                                color: secondaryTextColor, // Dynamic
                              ),
                            ),
                          ),
                        )
                      else
                        Column(
                          children: _comments
                              .map((c) => _buildCommentItem(c, isDark))
                              .toList(),
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Input Bar
          Positioned(
            left: DesignTokens.paddingMedium,
            right: DesignTokens.paddingMedium,
            bottom:
                DesignTokens.paddingMedium +
                MediaQuery.of(context).viewInsets.bottom,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: inputBgColor, // Dynamic
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: inputBorderColor, // Dynamic
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? DesignTokens.glassShadowDark
                            : DesignTokens.glassShadow.withOpacity(0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: TextStyle(
                            color: primaryTextColor,
                          ), // Dynamic Text
                          decoration: InputDecoration(
                            hintText: "Write a reply...",
                            hintStyle: TextStyle(
                              color: secondaryTextColor, // Dynamic Hint
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: DesignTokens.accentPrimary,
                        ),
                        onPressed: _handleSubmitComment,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, bool isDark) {
    final primaryTextColor = isDark
        ? DesignTokens.textPrimaryDark
        : DesignTokens.textPrimary;
    final secondaryTextColor = isDark
        ? DesignTokens.textSecondaryDark
        : DesignTokens.textSecondary;

    // Key is CRITICAL for preventing list jumps when data updates
    return Padding(
      key: ValueKey(comment.id),
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _navigateToProfile(comment.author.id),
              child: Avatar(user: comment.author, radius: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _navigateToProfile(comment.author.id),
                        child: Text(
                          comment.author.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: primaryTextColor, // Dynamic
                          ),
                        ),
                      ),
                      Text(
                        TimeFormatter.formatRelative(comment.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: secondaryTextColor, // Dynamic
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.text,
                    style: TextStyle(color: primaryTextColor), // Dynamic
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Post Media Viewer Class ---
class PostMediaViewer extends StatefulWidget {
  final Post post;
  final int initialIndex;

  const PostMediaViewer({
    super.key,
    required this.post,
    required this.initialIndex,
  });

  @override
  State<PostMediaViewer> createState() => _PostMediaViewerState();
}

class _PostMediaViewerState extends State<PostMediaViewer> {
  late PageController _pageController;
  late int _currentIndex;

  int get _itemCount {
    if (widget.post.mediaIds.isNotEmpty) {
      return widget.post.mediaIds.length;
    } else if (widget.post.imageUrl != null &&
        widget.post.imageUrl!.isNotEmpty) {
      return 1;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post.author.displayName,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              TimeFormatter.formatRelative(widget.post.timestamp),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _itemCount,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              Widget content;
              if (widget.post.mediaIds.isNotEmpty) {
                content = Hero(
                  tag: 'post_media_${widget.post.id}_$index',
                  child: CachedBase64Image(
                    mediaId: widget.post.mediaIds[index],
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                );
              } else {
                content = Hero(
                  tag: 'post_img_${widget.post.id}',
                  child: Image.network(
                    widget.post.imageUrl!,
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                );
              }
              return Center(
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: content,
                ),
              );
            },
          ),
          if (widget.post.content.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.6),
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  top: false,
                  child: Text(
                    widget.post.content,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// lib/screens/post_detail_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../data/feed_repository.dart';
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
  late Future<List<Comment>> _commentsFuture;
  List<Comment> _comments = [];

  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  void _fetchComments() {
    _commentsFuture = _repository.getComments(widget.post.id).then((val) {
      if (mounted) setState(() => _comments = val);
      return val;
    });
  }

  void _handleSubmitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    _commentController.clear();

    final newComment = await _repository.addComment(widget.post.id, text);

    if (newComment != null && mounted) {
      setState(() {
        _comments.insert(0, newComment);
      });
    }
  }

  void _navigateToProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen(userId: userId)),
    );
  }

  void _openMediaViewer(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PostMediaViewer(post: widget.post, initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                            // Author
                            GestureDetector(
                              onTap: () =>
                                  _navigateToProfile(widget.post.author.id),
                              child: Row(
                                children: [
                                  Avatar(user: widget.post.author, radius: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.post.author.displayName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text("@${widget.post.author.username}"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.post.content,
                              style: const TextStyle(fontSize: 18, height: 1.5),
                            ),

                            // --- MEDIA CAROUSEL ---
                            if (widget.post.mediaIds.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  height: 400, // Big view
                                  width: double.infinity,
                                  child: PageView.builder(
                                    itemCount: widget.post.mediaIds.length,
                                    onPageChanged: (index) {
                                      setState(
                                        () => _currentImageIndex = index,
                                      );
                                    },
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () => _openMediaViewer(index),
                                        child: Hero(
                                          tag:
                                              'post_media_${widget.post.id}_$index',
                                          child: CachedBase64Image(
                                            mediaId:
                                                widget.post.mediaIds[index],
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
                              // Dots
                              if (widget.post.mediaIds.length > 1)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      widget.post.mediaIds.length,
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
                                              : DesignTokens.glassBorder,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ] else if (widget.post.imageUrl != null &&
                                widget.post.imageUrl!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () => _openMediaViewer(0),
                                child: Hero(
                                  tag: 'post_img_${widget.post.id}',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      widget.post.imageUrl!,
                                      height: 400,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),
                            const Divider(),
                            Text(
                              "Comments (${_comments.length})",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      // Comments
                      FutureBuilder(
                        future: _commentsFuture,
                        builder: (context, snapshot) {
                          if (_comments.isEmpty &&
                              snapshot.connectionState ==
                                  ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return Column(
                            children: _comments
                                .map((c) => _buildCommentItem(c))
                                .toList(),
                          );
                        },
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
                    color: DesignTokens.glassWhite.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: DesignTokens.glassBorder,
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: DesignTokens.glassShadow.withOpacity(0.15),
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
                          decoration: const InputDecoration(
                            hintText: "Write a reply...",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
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

  Widget _buildCommentItem(Comment comment) {
    return Padding(
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        TimeFormatter.formatRelative(comment.timestamp),
                        style: const TextStyle(
                          fontSize: 10,
                          color: DesignTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.text,
                    style: const TextStyle(color: DesignTokens.textPrimary),
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

// --- New Post Media Viewer Class ---

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

  // Helper to determine total items based on post data structure
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
          // Image Slider
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

              // Handle "mediaIds" list logic
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
              }
              // Handle single "imageUrl" logic
              else {
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

          // Caption Overlay (Post Content)
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

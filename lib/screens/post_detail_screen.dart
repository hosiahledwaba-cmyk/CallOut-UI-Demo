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
import '../theme/design_tokens.dart';
import 'profile_screen.dart'; // Added Import

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

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      showBottomNav: false,
      body: Stack(
        children: [
          // Content
          Column(
            children: [
              const TopNav(title: "Post", showBack: true),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(DesignTokens.paddingMedium),
                  child: Column(
                    children: [
                      // Main Post
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header - Wrapped in GestureDetector
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
                            if (widget.post.imageUrl != null) ...[
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(widget.post.imageUrl!),
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

                      // Comment List
                      const SizedBox(height: 16),
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
                      // Extra space for floating input
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Input Bar
          Positioned(
            left: DesignTokens.paddingMedium,
            right: DesignTokens.paddingMedium,
            bottom:
                DesignTokens.paddingMedium +
                MediaQuery.of(
                  context,
                ).viewInsets.bottom, // Moves up with keyboard
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

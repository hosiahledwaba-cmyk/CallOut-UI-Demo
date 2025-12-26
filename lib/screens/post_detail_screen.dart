// lib/screens/post_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../data/feed_repository.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/avatar.dart';
import '../widgets/glass_card.dart';
import '../theme/design_tokens.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final FeedRepository _repository = FeedRepository();
  late Future<List<Comment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _commentsFuture = _repository.getComments(widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      showBottomNav: false,
      body: Column(
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
                        Row(
                          children: [
                            Avatar(user: widget.post.author, radius: 24),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.post.author.displayName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontSize: 18),
                                ),
                                Text("@${widget.post.author.username}"),
                              ],
                            ),
                          ],
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
                            child: Image.network(
                              widget.post.imageUrl!,
                              errorBuilder: (c, e, s) => const SizedBox(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            "Comments (${widget.post.comments})",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        // Dynamic Comments
                        FutureBuilder<List<Comment>>(
                          future: _commentsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final comments = snapshot.data ?? [];
                            return Column(
                              children: comments
                                  .map((c) => _buildCommentItem(c))
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Avatar(user: comment.author, radius: 12),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.author.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  comment.text,
                  style: const TextStyle(color: DesignTokens.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

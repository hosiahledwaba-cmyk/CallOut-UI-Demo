// lib/screens/feed_screen.dart
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/post_preview.dart';
import '../widgets/glass_card.dart';
import '../data/feed_repository.dart';
import '../models/post.dart';
import '../theme/design_tokens.dart';
import 'create_post_screen.dart';
import '../services/auth_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Future<List<Post>> _postsFuture;
  final FeedRepository _repository = FeedRepository();

  @override
  void initState() {
    super.initState();
    _refreshFeed();
  }

  void _refreshFeed() {
    setState(() {
      _postsFuture = _repository.getPosts();
    });
  }

  // Navigate to Create Post and refresh feed if post created
  void _navigateToCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );

    if (result == true) {
      _refreshFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check Permissions
    final currentUser = AuthService().currentUser;
    final bool canPost = currentUser?.isActivist ?? false;

    return GlassScaffold(
      currentTabIndex: 0,
      // Only show FAB if user is an Activist
      floatingActionButton: canPost
          ? FloatingActionButton(
              onPressed: _navigateToCreatePost,
              backgroundColor: DesignTokens.accentPrimary,
              child: const Icon(Icons.add),
            )
          : null,

      body: Column(
        children: [
          TopNav(
            title: "SafeSpace",
            showSettings: true,
            showNotificationIcon: true,
            extraActions: [
              IconButton(
                icon: const Icon(Icons.refresh, size: 22),
                color: DesignTokens.textPrimary,
                onPressed: _refreshFeed,
                tooltip: "Refresh Feed",
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<Post>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: DesignTokens.accentPrimary,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Connection Error"));
                }

                final posts = snapshot.data ?? [];

                return RefreshIndicator(
                  onRefresh: () async => _refreshFeed(),
                  color: DesignTokens.accentPrimary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(DesignTokens.paddingMedium),
                    itemCount: posts.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // SOS Header
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: DesignTokens.paddingMedium,
                          ),
                          child: GlassCard(
                            isAlert: true,
                            onTap: () {},
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.sos,
                                  color: DesignTokens.accentAlert,
                                  size: 32,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Emergency Help Needed? \nTap for immediate assistance.",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: DesignTokens.textPrimary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: DesignTokens.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return PostPreview(post: posts[index - 1]);
                    },
                  ),
                );
              },
            ),
          ),
          // Bottom padding logic handled by navbar inset
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

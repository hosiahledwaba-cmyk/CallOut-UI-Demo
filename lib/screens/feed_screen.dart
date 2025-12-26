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

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      currentTabIndex: 0,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
        },
        backgroundColor: DesignTokens.accentPrimary,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          TopNav(
            title: "SafeSpace",
            showSettings: true, // Show Settings on left
            showNotificationIcon: true, // Show Bell on right
            extraActions: [
              // Add a specific refresh button alongside the bell
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: DesignTokens.accentAlert,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Connection Error",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        TextButton(
                          onPressed: _refreshFeed,
                          child: const Text("Try Again"),
                        ),
                      ],
                    ),
                  );
                }

                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  return const Center(child: Text("No posts available."));
                }

                return RefreshIndicator(
                  onRefresh: () async => _refreshFeed(),
                  color: DesignTokens.accentPrimary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(DesignTokens.paddingMedium),
                    itemCount: posts.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
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
          // Spacer logic handled by padding in the new floating bottom nav,
          // but we keep a small safety margin here for the list end.
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

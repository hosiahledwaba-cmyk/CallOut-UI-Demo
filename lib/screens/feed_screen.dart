// lib/screens/feed_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/post_preview.dart';
import '../widgets/glass_card.dart';
// ignore: unused_import
import '../models/post.dart';
import '../theme/design_tokens.dart';
import 'create_post_screen.dart';
import '../services/auth_service.dart';
import '../state/app_state_notifier.dart'; // Import State

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // Removed local _postsFuture and _repository

  void _navigateToCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );

    if (result == true) {
      // Force refresh via provider
      context.read<AppStateNotifier>().refresh(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. WATCH GLOBAL STATE
    final appState = context.watch<AppStateNotifier>();
    final posts = appState.feed;

    final currentUser = AuthService().currentUser;
    final bool canPost = currentUser?.isActivist ?? false;

    return GlassScaffold(
      currentTabIndex: 0,
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
                // Manual refresh
                onPressed: () =>
                    context.read<AppStateNotifier>().refresh(force: true),
                tooltip: "Refresh Feed",
              ),
            ],
          ),
          Expanded(
            child: posts.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: DesignTokens.accentPrimary,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async =>
                        context.read<AppStateNotifier>().refresh(force: true),
                    color: DesignTokens.accentPrimary,
                    child: ListView.builder(
                      // KEY: Preserves scroll position
                      key: const PageStorageKey('global_feed_list'),
                      padding: const EdgeInsets.all(DesignTokens.paddingMedium),
                      itemCount: posts.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Header
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: DesignTokens.paddingMedium,
                            ),
                            child: const GlassCard(
                              isAlert: true,
                              child: Row(
                                children: [
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

                        // Post Item
                        final post = posts[index - 1];
                        return PostPreview(
                          key: ValueKey(post.id), // KEY: Matches data updates
                          post: post,
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

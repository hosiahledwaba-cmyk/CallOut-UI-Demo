// lib/screens/feed_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/post_preview.dart';
import '../widgets/glass_card.dart';
import '../theme/design_tokens.dart';
import 'create_post_screen.dart';
import '../services/auth_service.dart';
import '../state/app_state_notifier.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  void _navigateToCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );

    if (result == true) {
      context.read<AppStateNotifier>().refresh(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. WATCH GLOBAL STATE
    final appState = context.watch<AppStateNotifier>();
    final posts = appState.feed;

    final currentUser = AuthService().currentUser;
    // Activists can post, or anyone if you change policy
    final bool canPost = currentUser?.isActivist ?? true;

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
                      key: const PageStorageKey('global_feed_list'),
                      padding: const EdgeInsets.all(DesignTokens.paddingMedium),
                      // Add +1 for the Emergency Header
                      itemCount: posts.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Emergency Header
                          return const Padding(
                            padding: EdgeInsets.only(
                              bottom: DesignTokens.paddingMedium,
                            ),
                            child: GlassCard(
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

                        final post = posts[index - 1];
                        return PostPreview(key: ValueKey(post.id), post: post);
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

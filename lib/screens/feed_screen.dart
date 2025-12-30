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
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final hasData = context.read<AppStateNotifier>().feed.isNotEmpty;
    if (hasData) {
      setState(() => _isInitialLoading = false);
    }
    await context.read<AppStateNotifier>().refresh();
    if (mounted) {
      setState(() => _isInitialLoading = false);
    }
  }

  void _navigateToCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() => _isInitialLoading = true);
      await context.read<AppStateNotifier>().refresh(force: true);
      if (mounted) setState(() => _isInitialLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateNotifier>();
    final posts = appState.feed;
    final currentUser = AuthService().currentUser;
    final bool canPost = currentUser?.isActivist ?? true;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? DesignTokens.textPrimaryDark
        : DesignTokens.textPrimary;
    final iconColor = isDark
        ? DesignTokens.textSecondaryDark
        : DesignTokens.textSecondary;

    return GlassScaffold(
      currentTabIndex: 0,

      // UPDATED FAB
      floatingActionButton: canPost
          ? FloatingActionButton(
              onPressed: _navigateToCreatePost,
              backgroundColor: DesignTokens.accentPrimary,
              elevation: 4, // Slight shadow for depth
              shape: const CircleBorder(), // Forces perfect circle
              child: const Icon(Icons.add, color: Colors.white, size: 28),
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
                color: textColor,
                onPressed: () {
                  setState(() => _isInitialLoading = true);
                  _loadData();
                },
                tooltip: "Refresh Feed",
              ),
            ],
          ),
          Expanded(
            child: posts.isEmpty && _isInitialLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: DesignTokens.accentPrimary,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: DesignTokens.accentPrimary,
                    child: ListView.builder(
                      key: const PageStorageKey('global_feed_list'),
                      padding: const EdgeInsets.only(
                        left: DesignTokens.paddingMedium,
                        right: DesignTokens.paddingMedium,
                        top: DesignTokens.paddingMedium,
                        bottom:
                            120, // INCREASED PADDING so last post isn't hidden by FAB
                      ),
                      itemCount: posts.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: DesignTokens.paddingMedium,
                            ),
                            child: GlassCard(
                              isAlert: true,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.sos,
                                    color: DesignTokens.accentAlert,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Emergency Help Needed? \nTap for immediate assistance.",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, color: iconColor),
                                ],
                              ),
                            ),
                          );
                        }
                        final postIndex = index - 1;
                        if (postIndex >= posts.length) return const SizedBox();
                        return PostPreview(
                          key: ValueKey(posts[postIndex].id),
                          post: posts[postIndex],
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

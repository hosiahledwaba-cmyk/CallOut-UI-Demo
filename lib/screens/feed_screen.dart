// lib/screens/feed_screen.dart
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/post_preview.dart';
import '../widgets/glass_card.dart';
import '../data/mock_feed_repository.dart';
import '../theme/design_tokens.dart';
import 'create_post_screen.dart'; // Needed for the FAB action

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = MockFeedRepository.getPosts();

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
          const TopNav(title: "Community Feed"),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(DesignTokens.paddingMedium),
              itemCount: posts.length + 1, // +1 for SOS header
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: DesignTokens.paddingMedium,
                    ),
                    child: GlassCard(
                      isAlert: true,
                      onTap: () {}, // TODO: Trigger Emergency Dial
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
          ),
          const SizedBox(height: 80), // Spacer for bottom nav
        ],
      ),
    );
  }
}

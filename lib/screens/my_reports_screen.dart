// lib/screens/my_reports_screen.dart
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/post_preview.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../theme/design_tokens.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for specific user history
    final myPosts = [
      Post(
        id: 'p1',
        author: const User(
          id: 'me',
          username: 'me',
          displayName: 'Me',
          avatarUrl: 'https://i.pravatar.cc/150?u=99',
          isVerified: true,
          isActivist: true,
        ),
        content:
            "Update: The street lights on 5th Avenue have been fixed! Thank you to the council for the quick response.",
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        likes: 45,
        comments: 12,
      ),
      Post(
        id: 'p2',
        author: const User(
          id: 'me',
          username: 'me',
          displayName: 'Me',
          avatarUrl: 'https://i.pravatar.cc/150?u=99',
          isVerified: true,
          isActivist: true,
        ),
        content:
            "Reporting a safety hazard near the Central Park entrance. Please avoid the area after dark until further notice.",
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        likes: 120,
        comments: 34,
        isEmergency: true,
      ),
    ];

    return GlassScaffold(
      showBottomNav: false,
      body: Column(
        children: [
          const TopNav(title: "My Reports", showBack: true),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(DesignTokens.paddingMedium),
              itemCount: myPosts.length,
              itemBuilder: (context, index) {
                return PostPreview(post: myPosts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/avatar.dart';
import '../widgets/glass_card.dart';
import '../widgets/top_nav.dart';
import '../models/user.dart';
import '../theme/design_tokens.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock current user
    const user = User(
      id: 'me',
      username: 'jane_doe',
      displayName: 'Jane Doe',
      avatarUrl: 'https://i.pravatar.cc/150?u=99',
    );

    return GlassScaffold(
      currentTabIndex: 3,
      body: Column(
        children: [
          const TopNav(title: "My Profile"),
          Padding(
            padding: const EdgeInsets.all(DesignTokens.paddingMedium),
            child: Column(
              children: [
                const Avatar(user: user, radius: 50),
                const SizedBox(height: 16),
                Text(
                  user.displayName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  "@${user.username}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _StatItem(count: "12", label: "Posts"),
                    _StatItem(count: "340", label: "Following"),
                    _StatItem(count: "120", label: "Followers"),
                  ],
                ),
                const SizedBox(height: 24),
                GlassCard(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.history),
                        title: const Text("My Reports"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.bookmark_border),
                        title: const Text("Saved Resources"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: DesignTokens.textSecondary)),
      ],
    );
  }
}

// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/avatar.dart';
import '../widgets/glass_card.dart';
import '../widgets/top_nav.dart';
import '../models/user.dart';
import '../theme/design_tokens.dart';
import '../data/profile_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileRepository _repository = ProfileRepository();
  late Future<User> _userFuture;
  late Future<Map<String, String>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _repository.getUserProfile();
    _statsFuture = _repository.getUserStats();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      currentTabIndex: 3,
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError)
            return const Center(child: Text("Failed to load profile"));

          final user = snapshot.data!;

          return Column(
            children: [
              const TopNav(title: "My Profile"),
              Padding(
                padding: const EdgeInsets.all(DesignTokens.paddingMedium),
                child: Column(
                  children: [
                    Avatar(user: user, radius: 50),
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
                    FutureBuilder<Map<String, String>>(
                      future: _statsFuture,
                      builder: (context, statsSnap) {
                        final stats =
                            statsSnap.data ??
                            {"posts": "-", "following": "-", "followers": "-"};
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(count: stats['posts']!, label: "Posts"),
                            _StatItem(
                              count: stats['following']!,
                              label: "Following",
                            ),
                            _StatItem(
                              count: stats['followers']!,
                              label: "Followers",
                            ),
                          ],
                        );
                      },
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
          );
        },
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

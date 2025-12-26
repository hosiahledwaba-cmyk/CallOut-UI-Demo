// lib/screens/user_list_screen.dart
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_text_field.dart'; // Reused for search input style if needed, or GlassSearchBar
import '../widgets/search_bar.dart';
import '../widgets/avatar.dart';
import '../models/user.dart';
import '../theme/design_tokens.dart';

class UserListScreen extends StatefulWidget {
  final String title;

  const UserListScreen({super.key, required this.title});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  // Mock Data
  final List<User> _allUsers = [
    const User(
      id: 'u1',
      username: 'sarah_j',
      displayName: 'Sarah Jenkins',
      avatarUrl: 'https://i.pravatar.cc/150?u=1',
      isVerified: true,
    ),
    const User(
      id: 'u2',
      username: 'safe_zone',
      displayName: 'Safe Zone NGO',
      avatarUrl: 'https://i.pravatar.cc/150?u=2',
      isVerified: true,
      isActivist: true,
    ),
    const User(
      id: 'u3',
      username: 'dr_emily',
      displayName: 'Dr. Emily',
      avatarUrl: 'https://i.pravatar.cc/150?u=3',
      isVerified: true,
    ),
    const User(
      id: 'u5',
      username: 'alex_m',
      displayName: 'Alex M.',
      avatarUrl: 'https://i.pravatar.cc/150?u=5',
    ),
    const User(
      id: 'u6',
      username: 'jessica_p',
      displayName: 'Jessica P.',
      avatarUrl: 'https://i.pravatar.cc/150?u=6',
    ),
    const User(
      id: 'u7',
      username: 'comm_watch',
      displayName: 'Community Watch',
      avatarUrl: 'https://i.pravatar.cc/150?u=7',
      isVerified: true,
    ),
  ];

  List<User> _filteredUsers = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _filteredUsers = _allUsers;
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers
            .where(
              (u) =>
                  u.displayName.toLowerCase().contains(query.toLowerCase()) ||
                  u.username.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      showBottomNav: false,
      body: Column(
        children: [
          TopNav(title: widget.title, showBack: true),

          // Search Bar Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GlassSearchBar(onChanged: _onSearch),
          ),

          // User List
          Expanded(
            child: _filteredUsers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(DesignTokens.paddingMedium),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      return _UserListItem(user: _filteredUsers[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: DesignTokens.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No users found",
            style: TextStyle(
              fontSize: 18,
              color: DesignTokens.textSecondary.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserListItem extends StatefulWidget {
  final User user;

  const _UserListItem({required this.user});

  @override
  State<_UserListItem> createState() => _UserListItemState();
}

class _UserListItemState extends State<_UserListItem> {
  bool _isFollowing = false; // Mock local state

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Avatar(user: widget.user, radius: 24),
            const SizedBox(width: 16),

            // Name & Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.user.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: DesignTokens.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.user.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          size: 14,
                          color: DesignTokens.accentSafe,
                        ),
                      ],
                      if (widget.user.isActivist) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.shield,
                          size: 14,
                          color: DesignTokens.accentPrimary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "@${widget.user.username}",
                    style: const TextStyle(
                      color: DesignTokens.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Action Button
            SizedBox(
              width: 100,
              height: 36,
              child: GlassButton(
                label: _isFollowing ? "Following" : "Follow",
                isPrimary:
                    !_isFollowing, // Filled if not following, Glass if following
                onTap: () {
                  setState(() {
                    _isFollowing = !_isFollowing;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

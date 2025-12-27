// lib/screens/user_list_screen.dart
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import '../widgets/search_bar.dart';
import '../widgets/avatar.dart';
import '../models/user.dart';
import '../theme/design_tokens.dart';
import '../data/search_repository.dart';
import '../data/profile_repository.dart';

class UserListScreen extends StatefulWidget {
  final String title;

  const UserListScreen({super.key, required this.title});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final SearchRepository _searchRepo = SearchRepository();

  // Future to handle Async Data (API or Mock)
  late Future<List<User>> _usersFuture;
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    // Fetch users (Simulating getting followers/following list)
    _usersFuture = _searchRepo.searchUsers("").then((users) {
      if (mounted) {
        setState(() {
          _allUsers = users;
          _filteredUsers = users;
        });
      }
      return users;
    });
  }

  void _onSearch(String query) {
    setState(() {
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
            child: FutureBuilder<List<User>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: DesignTokens.accentPrimary,
                    ),
                  );
                }

                if (_filteredUsers.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(DesignTokens.paddingMedium),
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    return _UserListItem(user: _filteredUsers[index]);
                  },
                );
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
  final ProfileRepository _profileRepo = ProfileRepository();
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.user.isFollowing;
  }

  void _toggleFollow() {
    // 1. Optimistic UI Update
    setState(() {
      _isFollowing = !_isFollowing;
    });

    // 2. API Call (Background)
    _profileRepo.toggleFollow(widget.user.id, _isFollowing);
  }

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
                onTap: _toggleFollow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

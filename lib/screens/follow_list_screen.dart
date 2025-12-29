// lib/screens/follow_list_screen.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../data/profile_repository.dart';
import '../services/auth_service.dart'; // Import AuthService
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/avatar.dart';
import '../widgets/glass_card.dart';
import '../theme/design_tokens.dart';
import 'profile_screen.dart';

enum FollowListType { followers, following }

class FollowListScreen extends StatefulWidget {
  final String userId;
  final FollowListType type;

  const FollowListScreen({super.key, required this.userId, required this.type});

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  final ProfileRepository _repo = ProfileRepository();
  List<User> _users = [];
  bool _isLoading = true;
  String? _currentUserId; // Store current user ID

  @override
  void initState() {
    super.initState();
    _currentUserId = AuthService().currentUser?.id; // Get ID on init
    _fetchData();
  }

  void _fetchData() async {
    setState(() => _isLoading = true);

    List<User> results;
    if (widget.type == FollowListType.followers) {
      results = await _repo.getFollowers(widget.userId);
    } else {
      results = await _repo.getFollowing(widget.userId);
    }

    if (mounted) {
      setState(() {
        _users = results;
        _isLoading = false;
      });
    }
  }

  void _handleToggleFollow(User user) async {
    // Optimistic Update
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index == -1) return;

    final newState = !user.isFollowing;

    setState(() {
      _users[index] = user.copyWith(isFollowing: newState);
    });

    await _repo.toggleFollow(user.id, newState);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == FollowListType.followers
        ? "Followers"
        : "Following";

    return GlassScaffold(
      showBottomNav: false,
      body: Column(
        children: [
          TopNav(title: title, showBack: true),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: DesignTokens.accentPrimary,
                    ),
                  )
                : _users.isEmpty
                ? const Center(
                    child: Text(
                      "No users found",
                      style: TextStyle(color: DesignTokens.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(DesignTokens.paddingMedium),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return _buildUserItem(user);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(User user) {
    // Check if this user is me
    final isMe = user.id == _currentUserId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(userId: user.id),
                ),
              ),
              child: Avatar(user: user, radius: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(userId: user.id),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                    Text(
                      "@${user.username}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Only show the button if it's NOT me
            if (!isMe)
              GestureDetector(
                onTap: () => _handleToggleFollow(user),
                child: Opacity(
                  opacity: user.isFollowing ? 0.6 : 1.0,
                  child: Container(
                    height: 32,
                    width: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: DesignTokens.primaryGradient,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.borderRadiusSmall,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: DesignTokens.accentPrimary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      user.isFollowing ? "Following" : "Follow",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

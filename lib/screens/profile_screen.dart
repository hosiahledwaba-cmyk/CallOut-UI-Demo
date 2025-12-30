// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/avatar.dart';
import '../widgets/glass_card.dart';
import '../widgets/top_nav.dart';
import '../widgets/glass_button.dart';
import '../widgets/post_preview.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../services/auth_service.dart';
import '../data/profile_repository.dart';
import '../theme/design_tokens.dart';
import 'verification_screen.dart';
import 'chat_screen.dart';
import 'follow_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId; // Null = Me, String = Other User

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileRepository _repo = ProfileRepository();

  User? _user;
  List<Post> _posts = [];
  bool _isLoading = true;
  bool _isMe = false;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  void _fetchProfileData() async {
    final currentUserId = AuthService().currentUser?.id;
    final targetId = widget.userId ?? currentUserId;

    if (targetId == null) {
      setState(() => _isLoading = false);
      return;
    }

    _isMe = (targetId == currentUserId);

    try {
      final results = await Future.wait([
        _repo.getUserProfile(targetId),
        _repo.getUserPosts(targetId),
      ]);

      if (mounted) {
        setState(() {
          final profileResult = results[0] as User?;
          final postsResult = results[1] as List<Post>;

          if (profileResult == null) {
            _isLoading = false;
            return;
          }

          _user = profileResult;
          _posts = postsResult;
          _isFollowing = _user!.isFollowing;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleFollow() {
    setState(() => _isFollowing = !_isFollowing);
    if (_user != null) {
      _repo.toggleFollow(_user!.id, !_isFollowing);
    }
  }

  void _handleMessage() {
    if (_user == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(partner: _user!)),
    );
  }

  void _navigateToFollowList(FollowListType type) {
    if (_user == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FollowListScreen(userId: _user!.id, type: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Loading State
    if (_isLoading) {
      return const GlassScaffold(
        showBottomNav: false,
        body: Center(
          child: CircularProgressIndicator(color: DesignTokens.accentPrimary),
        ),
      );
    }

    // 2. Error State
    if (_user == null) {
      return GlassScaffold(
        showBottomNav: widget.userId == null,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Theme-aware text handled by GlassScaffold background,
              // but we set explict color to be safe
              const Text(
                "User not found or connection failed.",
                style: TextStyle(color: DesignTokens.textSecondary),
              ),
              const SizedBox(height: 16),
              GlassButton(
                label: "Retry",
                onTap: _fetchProfileData,
                isPrimary: true,
              ),
            ],
          ),
        ),
      );
    }

    // 3. Content State
    return GlassScaffold(
      currentTabIndex: widget.userId == null ? 3 : -1,
      showBottomNav: widget.userId == null,
      body: Column(
        children: [
          TopNav(
            title: _isMe ? "My Profile" : _user!.displayName,
            showBack: !_isMe,
            showSettings: _isMe,
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _fetchProfileData(),
              color: DesignTokens.accentPrimary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    if (_isMe) _buildMyDashboard() else _buildPublicActions(),
                    const SizedBox(height: 24),
                    const Divider(color: DesignTokens.glassBorder),
                    _buildPostsList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // Theme Check
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? DesignTokens.textPrimaryDark
        : DesignTokens.textPrimary;
    final secondaryColor = isDark
        ? DesignTokens.textSecondaryDark
        : DesignTokens.textSecondary;

    return Column(
      children: [
        Avatar(user: _user!, radius: 50),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _user!.displayName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor, // Dynamic
              ),
            ),
            if (_user!.isVerified) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.verified,
                color: DesignTokens.accentSafe,
                size: 22,
              ),
            ],
            if (_user!.isActivist) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.shield,
                color: DesignTokens.accentPrimary,
                size: 22,
              ),
            ],
          ],
        ),
        Text(
          "@${_user!.username}",
          style: TextStyle(
            color: secondaryColor, // Dynamic
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Community safety advocate. Believer in data-driven change. 🌍",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: primaryColor, // Dynamic
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("${_user!.postsCount}", "Posts"),
        _buildStatItem(
          "${_user!.followersCount}",
          "Followers",
          onTap: () => _navigateToFollowList(FollowListType.followers),
        ),
        _buildStatItem(
          "${_user!.followingCount}",
          "Following",
          onTap: () => _navigateToFollowList(FollowListType.following),
        ),
      ],
    );
  }

  Widget _buildStatItem(String count, String label, {VoidCallback? onTap}) {
    // Theme Check
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? DesignTokens.textPrimaryDark
        : DesignTokens.textPrimary;
    final secondaryColor = isDark
        ? DesignTokens.textSecondaryDark
        : DesignTokens.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor, // Dynamic
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: secondaryColor, // Dynamic
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicActions() {
    return Row(
      children: [
        Expanded(
          child: GlassButton(
            label: _isFollowing ? "Following" : "Follow",
            isPrimary: !_isFollowing,
            onTap: _handleFollow,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassButton(
            label: "Message",
            isPrimary: false,
            icon: Icons.chat_bubble_outline,
            onTap: _handleMessage,
          ),
        ),
      ],
    );
  }

  Widget _buildMyDashboard() {
    // Theme Check
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? DesignTokens.textPrimaryDark
        : DesignTokens.textPrimary;
    final secondaryColor = isDark
        ? DesignTokens.textSecondaryDark
        : DesignTokens.textSecondary;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: _user!.isActivist
                    ? DesignTokens.accentPrimary
                    : secondaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _user!.isActivist
                          ? "Activist Account"
                          : "Standard Account",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor, // Dynamic
                      ),
                    ),
                    Text(
                      _user!.isActivist
                          ? "You have full reporting access."
                          : "Verify to unlock features.",
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryColor, // Dynamic
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!_user!.isActivist) ...[
            const SizedBox(height: 12),
            GlassButton(
              label: "Complete Verification",
              isPrimary: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VerificationScreen()),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    if (_posts.isEmpty) {
      // Theme Check for Empty State
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final secondaryColor = isDark
          ? DesignTokens.textSecondaryDark
          : DesignTokens.textSecondary;

      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.grid_off,
              size: 48,
              color: secondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text("No posts yet", style: TextStyle(color: secondaryColor)),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return PostPreview(post: _posts[index]);
      },
    );
  }
}

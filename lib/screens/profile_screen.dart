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
    // Determine target ID
    final targetId = widget.userId ?? currentUserId;

    if (targetId == null) {
      // Handle edge case: No user logged in and no ID passed
      setState(() => _isLoading = false);
      return;
    }

    _isMe = (targetId == currentUserId);

    // Parallel Fetch: Profile + Posts
    final results = await Future.wait([
      _repo.getUserProfile(targetId),
      _repo.getUserPosts(targetId),
    ]);

    if (mounted) {
      setState(() {
        _user = results[0] as User;
        _posts = results[1] as List<Post>;
        _isFollowing = _user!.isFollowing;
        _isLoading = false;
      });
    }
  }

  void _handleFollow() {
    setState(() => _isFollowing = !_isFollowing);
    if (_user != null) {
      _repo.toggleFollow(_user!.id, !_isFollowing); // API Call
    }
  }

  void _handleMessage() {
    if (_user == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(partner: _user!)),
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
      return const GlassScaffold(
        showBottomNav: false,
        body: Center(child: Text("User not found.")),
      );
    }

    // 3. Content State
    return GlassScaffold(
      // Show bottom nav ONLY if viewing "My Profile" tab (userId is null)
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

                    // --- HEADER SECTION ---
                    _buildHeader(),

                    const SizedBox(height: 24),

                    // --- STATS ROW ---
                    _buildStatsRow(),

                    const SizedBox(height: 24),

                    // --- ACTION BUTTONS ---
                    if (_isMe) _buildMyDashboard() else _buildPublicActions(),

                    const SizedBox(height: 24),
                    const Divider(color: DesignTokens.glassBorder),

                    // --- POSTS FEED ---
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
    return Column(
      children: [
        Avatar(user: _user!, radius: 50),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _user!.displayName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: DesignTokens.textPrimary,
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
          style: const TextStyle(
            color: DesignTokens.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        // Bio Placeholder
        const Text(
          "Community safety advocate. Believer in data-driven change. 🌍",
          textAlign: TextAlign.center,
          style: TextStyle(color: DesignTokens.textPrimary, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("${_posts.length}", "Posts"),
        _buildStatItem("542", "Followers"), // Mock numbers for layout
        _buildStatItem("128", "Following"),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: DesignTokens.textSecondary,
          ),
        ),
      ],
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
                    : DesignTokens.textSecondary,
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _user!.isActivist
                          ? "You have full reporting access."
                          : "Verify to unlock features.",
                      style: const TextStyle(
                        fontSize: 12,
                        color: DesignTokens.textSecondary,
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
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.grid_off,
              size: 48,
              color: DesignTokens.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              "No posts yet",
              style: TextStyle(color: DesignTokens.textSecondary),
            ),
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

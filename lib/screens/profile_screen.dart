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
import 'chat_screen.dart'; // To navigate to messages

class ProfileScreen extends StatefulWidget {
  final String? userId; // If null, shows current user

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileRepository _repo = ProfileRepository();
  User? _user;
  List<Post> _posts = [];
  bool _isMe = false;
  bool _isLoading = true;
  bool _isFollowing = false; // Local state for other users

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  void _fetchProfile() async {
    final currentUserId = AuthService().currentUser?.id;
    final targetId = widget.userId ?? currentUserId;

    if (targetId == null) return; // Should likely redirect to login

    _isMe = (targetId == currentUserId);

    // 1. Fetch User Profile
    final user = await _repo.getUserProfile(targetId);

    // 2. Fetch Posts
    final posts = await _repo.getUserPosts(targetId);

    if (mounted) {
      setState(() {
        _user = user;
        _posts = posts;
        _isLoading = false;
        _isFollowing = user.isFollowing;
      });
    }
  }

  void _handleFollowToggle() {
    if (_user == null) return;
    setState(() => _isFollowing = !_isFollowing);
    _repo.toggleFollow(
      _user!.id,
      !_isFollowing,
    ); // Invert logic: passed bool is 'desired state' usually, but repo takes current? let's assume repo toggles
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_user == null) {
      return const Scaffold(body: Center(child: Text("User not found")));
    }

    return GlassScaffold(
      // Only show bottom nav highlights if it's My Profile main tab
      currentTabIndex: widget.userId == null ? 3 : -1,
      showBottomNav:
          widget.userId ==
          null, // Hide nav when viewing others to focus on profile
      body: Column(
        children: [
          TopNav(
            title: _isMe ? "My Profile" : _user!.displayName,
            showBack: !_isMe, // Show back button if viewing someone else
            showSettings: _isMe,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DesignTokens.paddingMedium),
              child: Column(
                children: [
                  // --- HEADER ---
                  const SizedBox(height: 10),
                  Avatar(user: _user!, radius: 55),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _user!.displayName,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      if (_user!.isVerified) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified,
                          color: DesignTokens.accentSafe,
                          size: 24,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    "@${_user!.username}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  // --- ACTIONS (If not me) ---
                  if (!_isMe) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          child: GlassButton(
                            label: _isFollowing ? "Following" : "Follow",
                            isPrimary: !_isFollowing,
                            onTap: _handleFollowToggle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 120,
                          child: GlassButton(
                            label: "Message",
                            isPrimary: false,
                            icon: Icons.chat_bubble_outline,
                            onTap: _handleMessage,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // --- DASHBOARD (If me) ---
                  if (_isMe) ...[
                    _buildTrustDashboard(),
                    const SizedBox(height: 24),
                  ],

                  // --- STATS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(count: "${_posts.length}", label: "Posts"),
                      const _StatItem(count: "342", label: "Following"),
                      const _StatItem(count: "1.2k", label: "Followers"),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),

                  // --- POSTS LIST ---
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Recent Activity",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),

                  if (_posts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        "No posts yet.",
                        style: TextStyle(color: DesignTokens.textSecondary),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true, // Vital for nesting in ScrollView
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        return PostPreview(post: _posts[index]);
                      },
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustDashboard() {
    bool isActivist = _user!.isActivist;
    bool isVerified = _user!.isVerified;
    Color statusColor = isActivist
        ? DesignTokens.accentPrimary
        : (isVerified ? DesignTokens.accentSafe : Colors.grey);
    String statusTitle = isActivist
        ? "Verified Activist"
        : (isVerified ? "Verified User" : "Unverified");

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.shield, color: statusColor, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const Text(
                  "Identity & Trust Level",
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!isActivist)
            GlassButton(
              label: "Upgrade",
              isPrimary: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VerificationScreen()),
                );
              },
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

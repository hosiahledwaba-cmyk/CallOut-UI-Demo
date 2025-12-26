// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/avatar.dart';
import '../widgets/glass_card.dart';
import '../widgets/top_nav.dart';
import '../widgets/glass_button.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../theme/design_tokens.dart';
import 'verification_screen.dart';
import 'my_reports_screen.dart';
import 'saved_resources_screen.dart';
import 'safety_checkins_screen.dart';
import 'user_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Grab current user from Auth Service
  User? _user = AuthService().currentUser;

  void _navigateToVerification() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VerificationScreen()),
    );

    if (result == true) {
      setState(() {
        if (_user != null) {
          _user = User(
            id: _user!.id,
            username: _user!.username,
            displayName: _user!.displayName,
            avatarUrl: _user!.avatarUrl,
            isVerified: true,
            isActivist: true,
          );
        }
      });
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const SizedBox();

    return GlassScaffold(
      currentTabIndex: 3,
      body: Column(
        children: [
          const TopNav(
            title: "Profile",
            showSettings: true,
            showNotificationIcon: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DesignTokens.paddingMedium),
              child: Column(
                children: [
                  // --- HEADER ---
                  const SizedBox(height: 10),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Avatar(user: _user!, radius: 55),
                      if (_user!.isVerified)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: DesignTokens.accentSafe,
                            size: 24,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user!.displayName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    "@${_user!.username}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  // --- IDENTITY & TRUST DASHBOARD ---
                  const SizedBox(height: 24),
                  _buildTrustDashboard(),

                  // --- STATS ---
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Clickable Stats
                      GestureDetector(
                        onTap: () => _navigateTo(const MyReportsScreen()),
                        child: const _StatItem(count: "2", label: "Reports"),
                      ),
                      GestureDetector(
                        onTap: () => _navigateTo(
                          const UserListScreen(title: "Following"),
                        ),
                        child: const _StatItem(count: "12", label: "Following"),
                      ),
                      GestureDetector(
                        onTap: () => _navigateTo(
                          const UserListScreen(title: "Followers"),
                        ),
                        child: const _StatItem(count: "5", label: "Followers"),
                      ),
                    ],
                  ),

                  // --- MENU ---
                  const SizedBox(height: 24),
                  GlassCard(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.history,
                            color: DesignTokens.accentPrimary,
                          ),
                          title: const Text("My Reports"),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: DesignTokens.textSecondary,
                          ),
                          onTap: () => _navigateTo(const MyReportsScreen()),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(
                            Icons.bookmark_border,
                            color: DesignTokens.accentPrimary,
                          ),
                          title: const Text("Saved Resources"),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: DesignTokens.textSecondary,
                          ),
                          onTap: () =>
                              _navigateTo(const SavedResourcesScreen()),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(
                            Icons.security,
                            color: DesignTokens.accentPrimary,
                          ),
                          title: const Text("Safety Check-ins"),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: DesignTokens.textSecondary,
                          ),
                          onTap: () =>
                              _navigateTo(const SafetyCheckinsScreen()),
                        ),
                      ],
                    ),
                  ),

                  // Extra padding for scrolling above bottom nav
                  const SizedBox(height: 100),
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
        : (isVerified ? "Verified User" : "Unverified Account");

    String statusDesc = isActivist
        ? "You have full posting & reporting privileges."
        : (isVerified
              ? "You can interact but cannot create public posts."
              : "Complete verification to unlock safety features.");

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
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
                        fontSize: 16,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusDesc,
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
          if (!isActivist) ...[
            const SizedBox(height: 16),
            GlassButton(
              label: isVerified ? "Upgrade to Activist" : "Verify Identity",
              isPrimary: !isVerified, // Primary CTA if unverified
              icon: Icons.fingerprint,
              onTap: _navigateToVerification,
            ),
          ],
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
    return Container(
      color: Colors.transparent, // Hit test area
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(color: DesignTokens.textSecondary),
          ),
        ],
      ),
    );
  }
}

// lib/screens/settings_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/glass_card.dart';
import '../theme/design_tokens.dart';
import '../app.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _handleLogout(BuildContext context) {
    AuthService().logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsProvider.of(context);

    return GlassScaffold(
      showBottomNav: false,
      body: Column(
        children: [
          const TopNav(title: "Settings", showBack: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(DesignTokens.paddingMedium),
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 8),
                  child: Text(
                    "Accessibility",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                GlassCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text("Reduce Transparency"),
                        subtitle: const Text(
                          "Solid backgrounds for better readability",
                        ),
                        value: settings?.reduceTransparency ?? false,
                        onChanged: (val) => settings?.toggleTransparency(val),
                        activeColor: DesignTokens.accentPrimary,
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text("Reduce Motion"),
                        subtitle: const Text("Minimize animations"),
                        value: settings?.reduceMotion ?? false,
                        onChanged: (val) => settings?.toggleMotion(val),
                        activeColor: DesignTokens.accentPrimary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 8),
                  child: Text(
                    "Account",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                GlassCard(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(CupertinoIcons.lock),
                        title: const Text("Privacy & Security"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: DesignTokens.accentAlert,
                        ),
                        title: const Text(
                          "Log Out",
                          style: TextStyle(color: DesignTokens.accentAlert),
                        ),
                        onTap: () => _handleLogout(context),
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

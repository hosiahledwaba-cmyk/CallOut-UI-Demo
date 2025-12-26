// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_text_field.dart';
import '../widgets/top_nav.dart';
import '../services/auth_service.dart';
import '../theme/design_tokens.dart';
import 'feed_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _handleSignup() async {
    setState(() => _isLoading = true);

    // Only sending Username and Password now
    final success = await AuthService().signup(
      _usernameController.text,
      _passController.text,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const FeedScreen()),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup failed. Password too short?")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      showBottomNav: false,
      body: Column(
        children: [
          const TopNav(title: "Create Account", showBack: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DesignTokens.paddingLarge),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Safety First.",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Secure your username now. \nComplete your profile verification later to post.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: DesignTokens.textSecondary),
                  ),
                  const SizedBox(height: 40),

                  // Simplified Form
                  GlassTextField(
                    hint: "Username",
                    icon: Icons.person_outline,
                    controller: _usernameController,
                  ),
                  const SizedBox(height: 16),
                  GlassTextField(
                    hint: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controller: _passController,
                  ),

                  const SizedBox(height: 32),
                  _isLoading
                      ? const CircularProgressIndicator(
                          color: DesignTokens.accentPrimary,
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: GlassButton(
                            label: "Create Account",
                            onTap: _handleSignup,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

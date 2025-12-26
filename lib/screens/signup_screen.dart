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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _handleSignup() async {
    setState(() => _isLoading = true);

    final success = await AuthService().signup(
      _nameController.text,
      _emailController.text,
      _passController.text,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      // Clear navigation stack and go to feed
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const FeedScreen()),
        (route) => false,
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
                  GlassTextField(
                    hint: "Full Name",
                    icon: Icons.person_outline,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),
                  GlassTextField(
                    hint: "Email",
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
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

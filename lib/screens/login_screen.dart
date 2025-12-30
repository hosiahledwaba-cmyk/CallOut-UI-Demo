// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_text_field.dart';
import '../services/auth_service.dart';
import '../theme/design_tokens.dart';
import 'signup_screen.dart';
import 'feed_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    // 1. Validate inputs
    if (_emailController.text.trim().isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a username and password."),
          backgroundColor: DesignTokens.accentAlert,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 2. Call Auth Service
    final success = await AuthService().login(
      _emailController.text.trim(),
      _passController.text,
    );

    setState(() => _isLoading = false);

    // 3. Handle Result
    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const FeedScreen()),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Failed. Please check your credentials."),
          backgroundColor: DesignTokens.accentAlert,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme Checks
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? DesignTokens.textPrimaryDark
        : DesignTokens.textPrimary;
    final secondaryTextColor = isDark
        ? DesignTokens.textSecondaryDark
        : DesignTokens.textSecondary;

    return GlassScaffold(
      showBottomNav: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shield_moon,
                size: 80,
                color: DesignTokens.accentPrimary,
              ),
              const SizedBox(height: 16),
              Text(
                "SafeSpace",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: primaryTextColor, // Dynamic
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your voice. Your safety.",
                style: TextStyle(
                  color: secondaryTextColor, // Dynamic
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
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
                      child: GlassButton(label: "Log In", onTap: _handleLogin),
                    ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                ),
                child: Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(
                    color: DesignTokens.accentSecondary,
                    fontWeight: FontWeight.bold,
                    shadows: isDark
                        ? [const Shadow(color: Colors.black54, blurRadius: 10)]
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

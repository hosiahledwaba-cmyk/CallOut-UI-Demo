// lib/widgets/glass_text_field.dart
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import 'glass_card.dart';

class GlassTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const GlassTextField({
    super.key,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    // --- THEME CHECK ---
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dynamic Colors
    final textColor = isDark
        ? DesignTokens.textPrimaryDark
        : DesignTokens.textPrimary;
    final hintColor = isDark
        ? DesignTokens.textSecondaryDark
        : DesignTokens.textSecondary;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        // Update: Dynamic Input Text Color
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          // Update: Dynamic Icon Color
          icon: Icon(icon, color: hintColor),
          border: InputBorder.none,
          hintText: hint,
          // Update: Dynamic Hint Text Color
          hintStyle: TextStyle(color: hintColor),
        ),
      ),
    );
  }
}

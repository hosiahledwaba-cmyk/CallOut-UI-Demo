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
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: const TextStyle(color: DesignTokens.textPrimary),
        decoration: InputDecoration(
          icon: Icon(icon, color: DesignTokens.textSecondary),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: DesignTokens.textSecondary),
        ),
      ),
    );
  }
}

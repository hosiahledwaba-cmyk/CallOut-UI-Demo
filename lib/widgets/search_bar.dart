// lib/widgets/search_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'glass_card.dart';
import '../theme/design_tokens.dart';

class GlassSearchBar extends StatelessWidget {
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  const GlassSearchBar({
    super.key,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      onTap: onTap,
      child: Row(
        children: [
          const Icon(CupertinoIcons.search, color: DesignTokens.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: IgnorePointer(
              ignoring: readOnly,
              child: TextField(
                onChanged: onChanged,
                decoration: const InputDecoration(
                  hintText: "Search topics, resources...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: DesignTokens.textSecondary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

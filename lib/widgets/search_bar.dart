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
    // 1. Check Theme
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            CupertinoIcons.search,
            color: isDark
                ? DesignTokens.textSecondaryDark
                : DesignTokens.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: IgnorePointer(
              ignoring: readOnly,
              child: TextField(
                onChanged: onChanged,
                // 2. Set Input Text Color
                style: TextStyle(
                  color: isDark
                      ? DesignTokens.textPrimaryDark
                      : DesignTokens.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: "Search topics, resources...",
                  border: InputBorder.none,
                  // 3. Set Hint Text Color
                  hintStyle: TextStyle(
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// lib/widgets/resource_filters.dart
import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../theme/design_tokens.dart';

class ResourceFilters extends StatelessWidget {
  final ResourceCategory? selectedCategory;
  final Function(ResourceCategory?) onCategorySelected;

  const ResourceFilters({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip(context, "All", null),
          _buildChip(context, "Police", ResourceCategory.police),
          _buildChip(context, "Medical", ResourceCategory.medical),
          _buildChip(context, "Shelters", ResourceCategory.shelter),
          _buildChip(context, "Legal", ResourceCategory.legal),
          _buildChip(context, "Counseling", ResourceCategory.counseling),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    ResourceCategory? category,
  ) {
    final isSelected = selectedCategory == category;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine colors based on Theme and Selection state
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isSelected) {
      backgroundColor = DesignTokens.accentPrimary;
      textColor = Colors.white;
      borderColor = Colors.transparent;
    } else {
      // Unselected State
      if (isDark) {
        backgroundColor = DesignTokens.glassDark; // Dark Glass
        textColor = DesignTokens.textPrimaryDark.withOpacity(0.8);
        borderColor = DesignTokens.glassBorderDark;
      } else {
        backgroundColor = DesignTokens.glassWhite.withOpacity(0.65);
        textColor = DesignTokens.textPrimary;
        borderColor = DesignTokens.glassBorder;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onCategorySelected(category),
        child: AnimatedContainer(
          duration: DesignTokens.durationFast,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: DesignTokens.accentPrimary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

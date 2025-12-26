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

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onCategorySelected(category),
        child: AnimatedContainer(
          duration: DesignTokens.durationFast,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? DesignTokens.accentPrimary
                : DesignTokens.glassWhite.withOpacity(0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? Colors.transparent : DesignTokens.glassBorder,
              width: 1,
            ),
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
              color: isSelected ? Colors.white : DesignTokens.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

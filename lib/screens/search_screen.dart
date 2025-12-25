// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/search_bar.dart';
import '../widgets/glass_card.dart';
import '../theme/design_tokens.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      currentTabIndex: 1,
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            GlassSearchBar(onChanged: (val) {}),
            const SizedBox(height: 20),
            Text(
              "Suggested Topics",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip("Legal Aid"),
                _buildChip("Counseling"),
                _buildChip("Shelters"),
                _buildChip("Self Defense"),
                _buildChip("Report Anonymous"),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Nearby Resources",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildResourceCard("Women's Clinic", "2.4 km away"),
                  _buildResourceCard("Central Police Station", "5.1 km away"),
                  _buildResourceCard("Hope Foundation", "1.2 km away"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: DesignTokens.glassWhite.withOpacity(0.5),
      elevation: 0,
    );
  }

  Widget _buildResourceCard(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GlassCard(
        child: ListTile(
          leading: const Icon(Icons.place, color: DesignTokens.accentSecondary),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.directions),
        ),
      ),
    );
  }
}

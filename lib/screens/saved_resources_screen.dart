// lib/screens/saved_resources_screen.dart
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/resource_carousel_card.dart';
import '../models/resource.dart';
import '../theme/design_tokens.dart';

class SavedResourcesScreen extends StatelessWidget {
  const SavedResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Saved Data
    final savedResources = [
      const Resource(
        id: 'r1',
        name: "St. Mary's Women's Clinic",
        description: "24/7 trauma care and counseling.",
        distance: "0.8 km",
        category: ResourceCategory.medical,
        phoneNumber: "111-222-3333",
        latitude: 0,
        longitude: 0,
        isOpenNow: true,
      ),
      const Resource(
        id: 'r3',
        name: "Legal Aid Society",
        description: "Free legal representation.",
        distance: "3.1 km",
        category: ResourceCategory.legal,
        phoneNumber: "555-LAW",
        latitude: 0,
        longitude: 0,
        isOpenNow: false,
      ),
    ];

    return GlassScaffold(
      showBottomNav: false,
      body: Column(
        children: [
          const TopNav(title: "Saved Resources", showBack: true),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: DesignTokens.paddingMedium,
              ),
              itemCount: savedResources.length,
              itemBuilder: (context, index) {
                // Reusing the card, but letting it expand horizontally in the list
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SizedBox(
                    height: 200, // Fixed height for the card layout
                    child: ResourceCarouselCard(
                      resource: savedResources[index],
                      onTap: () {}, // TODO: Open details
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

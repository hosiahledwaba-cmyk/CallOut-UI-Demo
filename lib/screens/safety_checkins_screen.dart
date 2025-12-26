// lib/screens/safety_checkins_screen.dart
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/top_nav.dart';
import '../theme/design_tokens.dart';

class SafetyCheckinsScreen extends StatelessWidget {
  const SafetyCheckinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      showBottomNav: false,
      body: Column(
        children: [
          const TopNav(title: "Safety Check-ins", showBack: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(DesignTokens.paddingMedium),
              children: [
                _buildCheckinItem(
                  "Home",
                  "Safe Arrival Confirmed",
                  "Today, 18:30",
                  Icons.home,
                  DesignTokens.accentSafe,
                ),
                _buildCheckinItem(
                  "City Center",
                  "Manual Check-in",
                  "Yesterday, 14:15",
                  Icons.location_on,
                  DesignTokens.accentPrimary,
                ),
                _buildCheckinItem(
                  "University Campus",
                  "Automated (Geofence)",
                  "24 Dec, 09:00",
                  Icons.school,
                  Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinItem(
    String title,
    String status,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(status),
          trailing: Text(
            time,
            style: const TextStyle(
              color: DesignTokens.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

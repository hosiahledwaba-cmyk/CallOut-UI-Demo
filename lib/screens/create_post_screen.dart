// lib/screens/create_post_screen.dart
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_card.dart';
import '../theme/design_tokens.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  bool isAnonymous = false;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      showBottomNav: false,
      body: Column(
        children: [
          TopNav(
            title: "Create Report",
            showBack: true,
            actions: [
              TextButton(
                onPressed: () {
                  // TODO: Post logic
                  Navigator.pop(context);
                },
                child: const Text(
                  "Post",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(DesignTokens.paddingMedium),
            child: Column(
              children: [
                GlassCard(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_pin,
                        color: DesignTokens.accentSecondary,
                      ),
                      const SizedBox(width: 12),
                      const Text("Post Anonymously?"),
                      const Spacer(),
                      Switch.adaptive(
                        value: isAnonymous,
                        onChanged: (val) => setState(() => isAnonymous = val),
                        activeColor: DesignTokens.accentPrimary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  height: 200,
                  child: const TextField(
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Share your story or report an incident...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        label: "Photo",
                        icon: Icons.camera_alt,
                        isPrimary: false,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassButton(
                        label: "Location",
                        icon: Icons.location_on,
                        isPrimary: false,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

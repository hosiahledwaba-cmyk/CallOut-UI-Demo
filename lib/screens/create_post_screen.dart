// lib/screens/create_post_screen.dart
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_card.dart';
import '../theme/design_tokens.dart';
import '../data/feed_repository.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  final FeedRepository _repository = FeedRepository();

  bool isAnonymous = false;
  bool _isPosting = false;

  void _handlePost() async {
    if (_contentController.text.trim().isEmpty) return;

    setState(() => _isPosting = true);

    // The repository handles the API call.
    // The backend uses the Auth Token to identify the user,
    // OR uses the 'isAnonymous' flag to mask the identity.
    final success = await _repository.createPost(
      _contentController.text,
      isAnonymous,
    );

    setState(() => _isPosting = false);

    if (success && mounted) {
      Navigator.pop(context, true); // Return 'true' to indicate refresh needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Post created successfully"),
          backgroundColor: DesignTokens.accentSafe,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to post. Please try again."),
          backgroundColor: DesignTokens.accentAlert,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      showBottomNav: false,
      body: Column(
        children: [
          TopNav(
            title: "Create Report",
            showBack: true,
            extraActions: [
              _isPosting
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: DesignTokens.accentPrimary,
                          ),
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: _handlePost,
                      child: const Text(
                        "Post",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.textPrimary,
                        ),
                      ),
                    ),
            ],
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DesignTokens.paddingMedium),
              child: Column(
                children: [
                  // Anonymous Toggle
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isAnonymous ? Icons.visibility_off : Icons.visibility,
                          color: isAnonymous
                              ? DesignTokens.accentPrimary
                              : DesignTokens.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Post Anonymously",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              isAnonymous
                                  ? "Your identity will be hidden."
                                  : "Posting as yourself.",
                              style: const TextStyle(
                                fontSize: 12,
                                color: DesignTokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
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

                  // Text Input
                  GlassCard(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      enabled: !_isPosting,
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        hintText:
                            "Share your story, report an incident, or ask for help...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Media Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          label: "Photo",
                          icon: Icons.camera_alt,
                          isPrimary: false,
                          onTap: () {}, // Future: Image Picker
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassButton(
                          label: "Location",
                          icon: Icons.location_on,
                          isPrimary: false,
                          onTap: () {}, // Future: Geolocator
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

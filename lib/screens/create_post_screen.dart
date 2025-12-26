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
    if (_contentController.text.isEmpty) return;

    setState(() => _isPosting = true);

    final success = await _repository.createPost(
      _contentController.text,
      isAnonymous,
    );

    setState(() => _isPosting = false);

    if (success && mounted) {
      Navigator.pop(context); // Return to feed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post created successfully")),
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
            // Updated parameter name to match the new TopNav widget
            extraActions: [
              _isPosting
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: _handlePost,
                      child: const Text(
                        "Post",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
          // Added Expanded and ScrollView to prevent keyboard overflow
          Expanded(
            child: SingleChildScrollView(
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
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      enabled: !_isPosting,
                      decoration: const InputDecoration(
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
                          onTap: () {}, // TODO: Image Picker logic
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassButton(
                          label: "Location",
                          icon: Icons.location_on,
                          isPrimary: false,
                          onTap: () {}, // TODO: Geolocator logic
                        ),
                      ),
                    ],
                  ),
                  // Add bottom padding for better scrolling experience
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

// lib/screens/create_post_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool isAnonymous = false;
  bool _isPosting = false;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not pick image.")));
    }
  }

  void _handlePost() async {
    if (_contentController.text.trim().isEmpty && _selectedImage == null)
      return;

    setState(() => _isPosting = true);

    final success = await _repository.createPost(
      _contentController.text,
      isAnonymous,
      imageFile: _selectedImage, // Pass the file here
    );

    setState(() => _isPosting = false);

    if (success && mounted) {
      Navigator.pop(context, true);
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

                  if (_selectedImage != null) ...[
                    const SizedBox(height: 16),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            DesignTokens.borderRadiusSmall,
                          ),
                          child: Image.file(
                            _selectedImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedImage = null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          label: _selectedImage == null
                              ? "Photo"
                              : "Change Photo",
                          icon: Icons.camera_alt,
                          isPrimary: false,
                          onTap: _pickImage,
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

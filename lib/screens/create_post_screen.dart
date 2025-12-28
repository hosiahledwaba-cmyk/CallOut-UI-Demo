// lib/screens/create_post_screen.dart
import 'dart:io';
import 'dart:ui'; // For ImageFilter
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

  List<File> _selectedImages = [];
  bool isAnonymous = false;
  bool _isPosting = false;

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum 10 images allowed.")),
      );
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          final remainingSlots = 10 - _selectedImages.length;
          final newFiles = images.take(remainingSlots).map((x) => File(x.path));
          _selectedImages.addAll(newFiles);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not pick images.")));
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _handlePost() async {
    if (_contentController.text.trim().isEmpty && _selectedImages.isEmpty)
      return;

    setState(() => _isPosting = true);

    final success = await _repository.createPost(
      _contentController.text,
      isAnonymous,
      imageFiles: _selectedImages,
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
                    height: 150,
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

                  // Multi-Image Preview with Smart Blur
                  if (_selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          final file = _selectedImages[index];
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 120,
                                height: 120,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // Background Blur
                                      Image.file(file, fit: BoxFit.cover),
                                      BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 5,
                                          sigmaY: 5,
                                        ),
                                        child: Container(
                                          color: Colors.black.withOpacity(0.3),
                                        ),
                                      ),
                                      // Foreground
                                      Image.file(file, fit: BoxFit.contain),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 16,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Media Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          label: _selectedImages.isEmpty
                              ? "Add Photos"
                              : "Add More (${_selectedImages.length}/10)",
                          icon: Icons.camera_alt,
                          isPrimary: false,
                          onTap: _pickImages,
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

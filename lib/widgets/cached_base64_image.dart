// lib/widgets/cached_base64_image.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/media_service.dart';
import '../theme/design_tokens.dart';

class CachedBase64Image extends StatefulWidget {
  final String mediaId;
  final double? height;
  final double? width;
  final BoxFit fit;

  const CachedBase64Image({
    super.key,
    required this.mediaId,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  State<CachedBase64Image> createState() => _CachedBase64ImageState();
}

class _CachedBase64ImageState extends State<CachedBase64Image> {
  File? _imageFile;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  // Reload when ID changes (important for lists)
  @override
  void didUpdateWidget(covariant CachedBase64Image oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaId != widget.mediaId) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final file = await MediaService().getMediaFile(widget.mediaId);

    if (mounted) {
      setState(() {
        _imageFile = file;
        _isLoading = false;
        _hasError = file == null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: widget.height ?? 200,
        width: widget.width,
        color: DesignTokens.glassBorder.withOpacity(0.1),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: DesignTokens.accentPrimary,
            ),
          ),
        ),
      );
    }

    if (_hasError || _imageFile == null) {
      return Container(
        height: widget.height ?? 200,
        width: widget.width,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image, color: Colors.grey),
            const SizedBox(height: 4),
            Text(
              "Failed to load",
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
            ),
          ],
        ),
      );
    }

    return Image.file(
      _imageFile!,
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
      gaplessPlayback: true, // Prevents flickering when scrolling
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: widget.height,
          width: widget.width,
          color: Colors.grey[200],
          child: const Icon(Icons.error, color: DesignTokens.accentAlert),
        );
      },
    );
  }
}

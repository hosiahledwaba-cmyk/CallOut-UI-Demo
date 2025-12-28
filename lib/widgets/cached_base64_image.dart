// lib/widgets/cached_base64_image.dart
import 'dart:io';
import 'dart:ui'; // Required for ImageFilter
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

  @override
  void didUpdateWidget(covariant CachedBase64Image oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaId != widget.mediaId) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    // Avoid resetting state if ID hasn't changed to prevent flickering
    if (_imageFile != null && !mounted) return;

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
    // 1. Loading State
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

    // 2. Error State
    if (_hasError || _imageFile == null) {
      return Container(
        height: widget.height ?? 200,
        width: widget.width,
        color: Colors.grey[200],
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.broken_image, color: Colors.grey)],
        ),
      );
    }

    // 3. Success State
    // If fit is CONTAIN, we use the "Blurred Background" technique
    if (widget.fit == BoxFit.contain) {
      return SizedBox(
        height: widget.height,
        width: widget.width,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer A: Blurred Background (Fills the space)
            Image.file(_imageFile!, fit: BoxFit.cover),
            // Layer B: Blur Effect & Darken
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  color: Colors.black.withOpacity(
                    0.4,
                  ), // Darken slightly so foreground pops
                ),
              ),
            ),
            // Layer C: Actual Image (Fits perfectly)
            Image.file(_imageFile!, fit: BoxFit.contain, gaplessPlayback: true),
          ],
        ),
      );
    }

    // Standard Render (Cover, Fill, etc.)
    return Image.file(
      _imageFile!,
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
      gaplessPlayback: true,
    );
  }
}

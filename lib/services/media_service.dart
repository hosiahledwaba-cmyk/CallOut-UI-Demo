// lib/services/media_service.dart
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../data/api_config.dart';

class MediaService {
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;
  MediaService._internal();

  // --- 1. COMPRESSION PIPELINE ---

  Future<File?> compressAndProcessImage(File file) async {
    final filePath = file.absolute.path;

    // FIX: Robust output path generation
    // Instead of searching for ".jp", we just append a suffix
    final lastDot = filePath.lastIndexOf('.');
    final basePath = lastDot != -1 ? filePath.substring(0, lastDot) : filePath;
    final outPath =
        "${basePath}_out_${DateTime.now().millisecondsSinceEpoch}.jpg";

    try {
      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: 85,
        minWidth: 1920,
        minHeight: 1080,
      );

      if (result == null) return null;

      int size = await result.length();
      if (size > 600 * 1024) {
        print("⚠️ Image too big ($size bytes). Re-compressing...");
        return await _forceCompress(File(result.path));
      }

      return File(result.path);
    } catch (e) {
      print("Compression Error: $e");
      // Fallback: Return original file if compression fails,
      // preventing the app from breaking completely.
      return file;
    }
  }

  Future<File?> _forceCompress(File file) async {
    final filePath = file.absolute.path;
    final outPath = "${filePath}_forced.jpg";
    try {
      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: 60,
        minWidth: 1280,
        minHeight: 720,
      );
      if (result == null) return null;
      return File(result.path);
    } catch (e) {
      return file;
    }
  }

  Future<String> convertToBase64(File file) async {
    List<int> imageBytes = await file.readAsBytes();
    return base64Encode(imageBytes);
  }

  // --- 2. UPLOAD ---

  Future<bool> uploadMedia(
    String ownerId,
    File imageFile, {
    String type = "post",
  }) async {
    try {
      print("📸 Processing $type image for upload...");
      final processedFile = await compressAndProcessImage(imageFile);
      if (processedFile == null) return false;

      final base64String = await convertToBase64(processedFile);

      print("⬆️ Uploading to ${ApiConfig.media}...");
      final response = await http.post(
        Uri.parse(ApiConfig.media),
        headers: ApiConfig.headers,
        body: jsonEncode({
          "owner_id": ownerId,
          "base64_data": base64String,
          "context": type,
        }),
      );

      // Clean up processed file if it's a copy
      if (await processedFile.exists() &&
          processedFile.path != imageFile.path) {
        await processedFile.delete();
      }

      if (response.statusCode == 201) {
        print("✅ $type Upload Successful");
        return true;
      } else {
        print("❌ Upload Failed: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Upload Exception: $e");
      return false;
    }
  }

  // --- 3. RETRIEVAL & CACHING ---

  Future<File?> getMediaFile(String mediaId) async {
    final directory = await getTemporaryDirectory();
    final String filePath = '${directory.path}/media_$mediaId.jpg';
    final File file = File(filePath);

    // 1. Check Cache
    if (await file.exists()) {
      if (await file.length() > 0) return file;
      await file.delete(); // Delete corrupt 0-byte files
    }

    // 2. Fetch from API
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/media/$mediaId"),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String base64Str = data['base64_data'];

        if (base64Str.isEmpty) return null;

        final bytes = base64Decode(base64Str);
        await file.writeAsBytes(bytes, flush: true);

        return file;
      } else {
        print("❌ Download Failed ($mediaId): ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Fetch Exception: $e");
    }
    return null;
  }

  // --- 4. CLEANUP (TTL) ---
  Future<void> cleanOldCache() async {
    try {
      final directory = await getTemporaryDirectory();
      if (!await directory.exists()) return;

      final List<FileSystemEntity> files = directory.listSync();
      final now = DateTime.now();

      for (var file in files) {
        if (file.path.contains('media_')) {
          final stat = await file.stat();
          if (now.difference(stat.accessed).inDays > 2) {
            try {
              await file.delete();
            } catch (e) {
              // Ignore
            }
          }
        }
      }
    } catch (e) {
      print("Cache cleanup error: $e");
    }
  }
}

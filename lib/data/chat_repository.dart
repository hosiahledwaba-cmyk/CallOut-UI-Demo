// lib/data/chat_repository.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/user.dart';
import 'api_config.dart';
import '../services/media_service.dart'; // Using helper methods from here

class ChatRepository {
  // 1. Get list of active chats
  Future<List<User>> getActiveChats() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.chats), headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => User.fromJson(e)).toList();
      }
      throw Exception('Failed to load chats');
    } catch (e) {
      return [];
    }
  }

  // 2. Get Messages
  Future<List<Message>> getMessages(String partnerId) async {
    try {
      final url = ApiConfig.chatMessages.replaceAll('{id}', partnerId);

      final response = await http
          .get(Uri.parse(url), headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => Message.fromJson(e)).toList();
      }
      throw Exception('Failed to load messages');
    } catch (e) {
      return [];
    }
  }

  // 3. Send Message (Supports Text + Image)
  Future<Message?> sendMessage(
    String partnerId,
    String text, {
    File? imageFile,
  }) async {
    try {
      String? attachmentId;

      // STEP 1: Upload Media if exists
      if (imageFile != null) {
        attachmentId = await _uploadChatMedia(imageFile);
        // If upload fails, we abort sending the message to prevent confusion
        if (attachmentId == null) {
          print("Media upload failed, aborting message");
          return null;
        }
      }

      // STEP 2: Send Message with Link
      final url = ApiConfig.chatMessages.replaceAll('{id}', partnerId);

      final response = await http
          .post(
            Uri.parse(url),
            headers: ApiConfig.headers,
            body: jsonEncode({
              'text': text,
              'media_id': attachmentId, // Send the ID we just got
            }),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Message.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("Send Message Error: $e");
      return null;
    }
    return null;
  }

  // Private helper to handle Chat-Specific Media Uploads
  Future<String?> _uploadChatMedia(File file) async {
    try {
      // 1. Compress (Reuse existing service logic)
      final processedFile = await MediaService().compressAndProcessImage(file);
      if (processedFile == null) return null;

      // 2. Encode
      final base64Str = await MediaService().convertToBase64(processedFile);

      // 3. Upload
      // CRITICAL UPDATE:
      // - Changed 'post_id' to 'owner_id' to match backend generic model.
      // - Added "context": "chat" to route it to the chat_media collection.
      final response = await http.post(
        Uri.parse(ApiConfig.media),
        headers: ApiConfig.headers,
        body: jsonEncode({
          "owner_id": "chat_upload", // Generic ID context
          "base64_data": base64Str,
          "context": "chat", // Tells backend to put in chat_media
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id']; // Return the Media ID
      } else {
        print("Chat Media Upload Failed: ${response.body}");
      }
    } catch (e) {
      print("Chat Media Upload Exception: $e");
    }
    return null;
  }
}

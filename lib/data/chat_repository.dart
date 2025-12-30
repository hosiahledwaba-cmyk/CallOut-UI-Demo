// lib/data/chat_repository.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/user.dart';
import 'api_config.dart';
import '../services/media_service.dart';

class ChatRepository {
  // 1. Get active chats
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
      return [];
    } catch (e) {
      return [];
    }
  }

  // 3. Send Message (Handles Text, Image, and Shared Posts)
  Future<Message?> sendMessage(
    String partnerId,
    String text, {
    File? imageFile,
    String? sharedPostId, // New Parameter
  }) async {
    try {
      String? attachmentId;
      String messageType = 'text';

      // CASE A: Image Upload
      if (imageFile != null) {
        attachmentId = await _uploadChatMedia(imageFile);
        if (attachmentId == null) {
          print("Media upload failed, aborting message");
          return null;
        }
        messageType = 'image';
      }
      // CASE B: Shared Post
      else if (sharedPostId != null) {
        // We pass the post ID in the request, backend will embed the post object
        messageType = 'post';
      }

      final url = ApiConfig.chatMessages.replaceAll('{id}', partnerId);

      // Construct Request Body
      final body = {
        'text': text,
        'type': messageType,
        if (messageType == 'image') 'media_id': attachmentId,
        if (messageType == 'post') 'shared_post_id': sharedPostId,
      };

      final response = await http
          .post(
            Uri.parse(url),
            headers: ApiConfig.headers,
            body: jsonEncode(body),
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

  // Helper: Upload Media
  Future<String?> _uploadChatMedia(File file) async {
    try {
      final processedFile = await MediaService().compressAndProcessImage(file);
      if (processedFile == null) return null;

      final base64Str = await MediaService().convertToBase64(processedFile);

      final response = await http.post(
        Uri.parse(ApiConfig.media),
        headers: ApiConfig.headers,
        body: jsonEncode({
          "owner_id": "chat_upload",
          "base64_data": base64Str,
          "context": "chat",
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'];
      } else {
        print("Chat Media Upload Failed: ${response.body}");
      }
    } catch (e) {
      print("Chat Media Upload Exception: $e");
    }
    return null;
  }
}

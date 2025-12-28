// lib/data/chat_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/user.dart';
import 'api_config.dart';

class ChatRepository {
  // 1. Get list of active chats (For now, just a contact list)
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

  // 2. Get Messages for a specific partner
  // Note: 'chatId' argument here is actually the PARTNER'S USER ID
  Future<List<Message>> getMessages(String partnerId) async {
    try {
      // The backend expects /chats/{partner_id}/messages
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

  // 3. Send Message
  Future<Message?> sendMessage(String partnerId, String text) async {
    try {
      final url = ApiConfig.chatMessages.replaceAll('{id}', partnerId);

      final response = await http
          .post(
            Uri.parse(url),
            headers: ApiConfig.headers,
            body: jsonEncode({'text': text}),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 201) {
        return Message.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      // Optimistic response for better UX even if offline/failed
      return null;
    }
    return null;
  }
}

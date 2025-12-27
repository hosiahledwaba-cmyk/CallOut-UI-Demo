// lib/data/chat_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/user.dart';
import 'api_config.dart';

class ChatRepository {
  Future<List<User>> getActiveChats() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.chats), headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => User.fromJson(e)).toList();
      }
      throw Exception('Failed');
    } catch (e) {
      // Mock Data
      return [
        const User(
          id: 'u3',
          username: 'dr_emily',
          displayName: 'Dr. Emily',
          avatarUrl: 'https://i.pravatar.cc/150?u=3',
          isVerified: true,
        ),
        User.anonymous,
      ];
    }
  }

  Future<List<Message>> getMessages(String chatId) async {
    try {
      final url = ApiConfig.chatMessages.replaceAll('{id}', chatId);

      final response = await http
          .get(Uri.parse(url), headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => Message.fromJson(e)).toList();
      }
      throw Exception('Failed');
    } catch (e) {
      // Mock Conversation
      final partner = const User(
        id: 'u3',
        username: 'dr_emily',
        displayName: 'Dr. Emily',
        avatarUrl: 'https://i.pravatar.cc/150?u=3',
      );
      final me = const User(
        id: 'me',
        username: 'me',
        displayName: 'Me',
        avatarUrl: '',
      );

      return [
        Message(
          id: 'm1',
          sender: partner,
          text: "Hello! How can I help?",
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Message(
          id: 'm2',
          sender: me,
          text: "Looking for shelter info.",
          timestamp: DateTime.now().subtract(const Duration(hours: 20)),
        ),
        Message(
          id: 'm3',
          sender: partner,
          text: "I can help with that.",
          timestamp: DateTime.now().subtract(const Duration(hours: 19)),
        ),
      ];
    }
  }

  Future<Message?> sendMessage(String chatId, String text) async {
    try {
      final url = ApiConfig.chatMessages.replaceAll('{id}', chatId);

      final response = await http
          .post(
            Uri.parse(url),
            headers: ApiConfig.headers,
            body: jsonEncode({'text': text}),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 201)
        return Message.fromJson(jsonDecode(response.body));
    } catch (e) {
      // Optimistic Mock Response
      return Message(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        sender: const User(
          id: 'me',
          username: 'me',
          displayName: 'Me',
          avatarUrl: '',
        ),
        text: text,
        timestamp: DateTime.now(),
      );
    }
    return null;
  }
}

// lib/data/chat_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/user.dart';
import 'api_config.dart';

class ChatRepository {
  /// Fetches list of active conversations (users).
  Future<List<User>> getActiveChats() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.chats),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => User.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load chats');
      }
    } catch (e) {
      print("API Error (Chats): $e. Returning Mock Data.");
      return _getMockActiveChats();
    }
  }

  /// Fetches messages for a specific chat ID.
  Future<List<Message>> getMessages(String chatId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.chats}/$chatId/messages"),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Message.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print("API Error (Messages): $e. Returning Mock Data.");
      return _getMockMessages();
    }
  }

  /// Sends a message.
  Future<Message?> sendMessage(String chatId, String text) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.chats}/$chatId/messages"),
        headers: ApiConfig.headers,
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 201) {
        return Message.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print("API Error (Send Message): $e");
      // Simulate success for UI
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
  }

  // --- MOCK FALLBACK DATA ---
  List<User> _getMockActiveChats() {
    return [
      const User(
        id: 'u3',
        username: 'dr_emily',
        displayName: 'Dr. Emily (Counselor)',
        avatarUrl: 'https://i.pravatar.cc/150?u=3',
        isVerified: true,
      ),
      User.anonymous,
    ];
  }

  List<Message> _getMockMessages() {
    final User currentUser = const User(
      id: 'me',
      username: 'me',
      displayName: 'Me',
      avatarUrl: 'https://i.pravatar.cc/150?u=99',
    );

    final User chatPartner = const User(
      id: 'u3',
      username: 'dr_emily',
      displayName: 'Dr. Emily (Counselor)',
      avatarUrl: 'https://i.pravatar.cc/150?u=3',
      isVerified: true,
    );

    return [
      Message(
        id: 'm1',
        sender: chatPartner,
        text:
            "Hello! I saw your request for resources. How can I assist you today?",
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Message(
        id: 'm2',
        sender: currentUser,
        text: "Hi Dr. Emily. I'm looking for local shelters in District 9.",
        timestamp: DateTime.now().subtract(const Duration(hours: 20)),
      ),
      Message(
        id: 'm3',
        sender: chatPartner,
        text: "I can certainly help with that. Here is a secure list...",
        timestamp: DateTime.now().subtract(const Duration(hours: 19)),
      ),
    ];
  }
}

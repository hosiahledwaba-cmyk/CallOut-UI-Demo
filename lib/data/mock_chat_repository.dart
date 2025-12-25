// lib/data/mock_chat_repository.dart
import '../models/message.dart';
import '../models/user.dart';

class MockChatRepository {
  static final User _currentUser = User(
    id: 'me',
    username: 'me',
    displayName: 'Me',
    avatarUrl: 'https://i.pravatar.cc/150?u=99',
  );

  static final User _chatPartner = User(
    id: 'u3',
    username: 'dr_emily',
    displayName: 'Dr. Emily (Counselor)',
    avatarUrl: 'https://i.pravatar.cc/150?u=3',
    isVerified: true,
  );

  static List<Message> getMessages() {
    return [
      Message(
        id: 'm1',
        sender: _chatPartner,
        text:
            "Hello! I saw your request for resources. How can I assist you today?",
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Message(
        id: 'm2',
        sender: _currentUser,
        text: "Hi Dr. Emily. I'm looking for local shelters in District 9.",
        timestamp: DateTime.now().subtract(const Duration(hours: 20)),
      ),
      Message(
        id: 'm3',
        sender: _chatPartner,
        text: "I can certainly help with that. Here is a secure list...",
        timestamp: DateTime.now().subtract(const Duration(hours: 19)),
      ),
    ];
  }

  static List<User> getActiveChats() {
    return [_chatPartner, User.anonymous];
  }
}

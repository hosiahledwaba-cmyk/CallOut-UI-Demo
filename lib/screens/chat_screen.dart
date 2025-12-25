// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../data/mock_chat_repository.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/message_bubble.dart';
import '../widgets/glass_card.dart';
import '../theme/design_tokens.dart';

class ChatScreen extends StatelessWidget {
  final User partner;

  const ChatScreen({super.key, required this.partner});

  @override
  Widget build(BuildContext context) {
    final messages = MockChatRepository.getMessages();

    return GlassScaffold(
      showBottomNav: false,
      body: Column(
        children: [
          TopNav(title: partner.displayName, showBack: true),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              reverse:
                  true, // Usually chats are reversed, but for static list we iterate normal or reverse data
              itemCount: messages.length,
              itemBuilder: (context, index) {
                // Mock data is old->new, UI usually new->old at bottom.
                // Let's just render them top down for simplicity
                final msg = messages[index];
                return MessageBubble(message: msg, isMe: msg.sender.id == 'me');
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(DesignTokens.paddingMedium),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.add, color: DesignTokens.accentPrimary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: DesignTokens.accentPrimary,
                    ),
                    onPressed: () {}, // TODO: Send message
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

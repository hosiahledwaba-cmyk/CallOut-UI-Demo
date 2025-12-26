// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../data/chat_repository.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/message_bubble.dart';
import '../widgets/glass_card.dart';
import '../theme/design_tokens.dart';

class ChatScreen extends StatefulWidget {
  final User partner;

  const ChatScreen({super.key, required this.partner});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatRepository _repository = ChatRepository();
  late Future<List<Message>> _messagesFuture;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messagesFuture = _repository.getMessages(widget.partner.id);
  }

  void _sendMessage() async {
    if (_textController.text.isEmpty) return;

    // Optimistic UI update or wait for API
    final text = _textController.text;
    _textController.clear();

    await _repository.sendMessage(widget.partner.id, text);

    // Refresh list
    setState(() {
      _messagesFuture = _repository.getMessages(widget.partner.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      showBottomNav: false,
      body: Column(
        children: [
          TopNav(title: widget.partner.displayName, showBack: true),
          Expanded(
            child: FutureBuilder<List<Message>>(
              future: _messagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return MessageBubble(
                      message: msg,
                      isMe: msg.sender.id == 'me',
                    );
                  },
                );
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
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
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
                    onPressed: _sendMessage,
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

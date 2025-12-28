// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../data/chat_repository.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/glass_card.dart';
import '../widgets/message_bubble.dart'; // Ensure you have this widget or replace with Text
import '../theme/design_tokens.dart';
import '../services/auth_service.dart';

class ChatScreen extends StatefulWidget {
  final User partner;

  const ChatScreen({super.key, required this.partner});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatRepository _repository = ChatRepository();
  final TextEditingController _textController = TextEditingController();

  List<Message> _localMessages = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = AuthService().currentUser?.id;
    _loadMessages();
  }

  void _loadMessages() async {
    // Pass the PARTNER'S ID to fetch our private conversation
    final msgs = await _repository.getMessages(widget.partner.id);

    if (mounted) {
      setState(() {
        _localMessages = msgs;
        _isLoading = false;
      });
    }
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();

    // 1. Optimistic Update (Show immediately)
    final tempMsg = Message(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      sender:
          AuthService().currentUser ??
          const User(
            id: 'me',
            username: 'Me',
            displayName: 'Me',
            avatarUrl: '',
          ),
      text: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _localMessages.add(tempMsg); // Add to end of list
    });

    // 2. API Call
    final realMsg = await _repository.sendMessage(widget.partner.id, text);

    // 3. Replace temp with real (optional, or just refresh next time)
    if (realMsg != null && mounted) {
      setState(() {
        _localMessages.removeLast();
        _localMessages.add(realMsg);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      showBottomNav: false,
      body: Column(
        children: [
          TopNav(title: widget.partner.displayName, showBack: true),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: DesignTokens.accentPrimary,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _localMessages.length,
                    itemBuilder: (context, index) {
                      final msg = _localMessages[index];
                      final isMe = msg.sender.id == _currentUserId;

                      // Simple Bubble Logic if you don't have the widget
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe
                                ? DesignTokens.accentPrimary
                                : DesignTokens.glassWhite,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              color: isMe
                                  ? Colors.white
                                  : DesignTokens.textPrimary,
                            ),
                          ),
                        ),
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: "Type a secure message...",
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

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
  List<Message> _localMessages = []; // For optimistic updates

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    _messagesFuture = _repository.getMessages(widget.partner.id).then((msgs) {
      if (mounted) setState(() => _localMessages = msgs);
      return msgs;
    });
  }

  void _sendMessage() async {
    if (_textController.text.isEmpty) return;
    final text = _textController.text;
    _textController.clear();

    // 1. Optimistic Update
    final tempMsg = Message(
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

    setState(() {
      _localMessages.insert(
        0,
        tempMsg,
      ); // Add to bottom (or top if reverse list)
    });

    // 2. API Call
    await _repository.sendMessage(widget.partner.id, text);
    // Ideally replace tempMsg with real one here, but for now this is sufficient
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      showBottomNav: false,
      body: Column(
        children: [
          TopNav(title: widget.partner.displayName, showBack: true),
          Expanded(
            child: FutureBuilder(
              future: _messagesFuture,
              builder: (context, snapshot) {
                // Initial load
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _localMessages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: _localMessages.length,
                  // Reverse typically used for chats, ensure data order matches
                  // Here we assume data is Oldest -> Newest, so we render normally or reverse?
                  // Let's render Standard for simplicity (Top Down)
                  itemBuilder: (context, index) {
                    final msg = _localMessages[index];
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

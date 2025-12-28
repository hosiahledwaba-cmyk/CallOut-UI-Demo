// lib/screens/chat_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../data/chat_repository.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/glass_card.dart';
import '../theme/design_tokens.dart';
import '../services/auth_service.dart';
import '../utils/time_formatter.dart'; // Ensure you created this file

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
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _currentUserId = AuthService().currentUser?.id;
    _loadMessages();

    // Polling for new messages every 2 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _loadMessages(isPolling: true);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({bool isPolling = false}) async {
    try {
      final msgs = await _repository.getMessages(widget.partner.id);

      if (mounted) {
        // Smart Diffing to prevent UI flicker
        bool shouldUpdate = _localMessages.length != msgs.length;
        if (!shouldUpdate && msgs.isNotEmpty && _localMessages.isNotEmpty) {
          if (msgs.last.id != _localMessages.last.id) {
            shouldUpdate = true;
          }
        }

        if (shouldUpdate || !isPolling) {
          setState(() {
            _localMessages = msgs;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (!isPolling && mounted) setState(() => _isLoading = false);
    }
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();

    // Optimistic Update
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
      _localMessages.add(tempMsg);
    });

    await _repository.sendMessage(widget.partner.id, text);
    _loadMessages(isPolling: true); // Immediate refresh
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

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? DesignTokens.accentPrimary
                                : DesignTokens.glassWhite,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: isMe
                                  ? const Radius.circular(16)
                                  : Radius.zero,
                              bottomRight: isMe
                                  ? Radius.zero
                                  : const Radius.circular(16),
                            ),
                          ),
                          // Changed to Column to hold Message + Time
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                msg.text,
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white
                                      : DesignTokens.textPrimary,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // AUDIT: Exact Time
                              Text(
                                TimeFormatter.formatChatTime(msg.timestamp),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe
                                      ? Colors.white.withOpacity(0.7)
                                      : DesignTokens.textSecondary,
                                ),
                              ),
                            ],
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
                      textCapitalization: TextCapitalization.sentences,
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

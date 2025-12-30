// lib/screens/chat_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../data/chat_repository.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/message_bubble.dart';
import '../widgets/glass_card.dart';
import '../theme/design_tokens.dart';
import '../services/auth_service.dart';
import '../utils/merge_utils.dart';

class ChatScreen extends StatefulWidget {
  final User partner;

  const ChatScreen({super.key, required this.partner});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatRepository _repo = ChatRepository();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> _messages = [];
  Timer? _timer;
  bool _isFetching = false;
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = AuthService().currentUser?.id ?? '';
    _fetchMessages(force: true);
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _fetchMessages(),
    );
  }

  Future<void> _fetchMessages({bool force = false}) async {
    if (_isFetching && !force) return;
    if (!mounted) return;

    _isFetching = true;
    try {
      final incoming = await _repo.getMessages(widget.partner.id);

      if (incoming.isEmpty && _messages.isEmpty) {
        if (mounted) setState(() {});
        return;
      }

      final merged = MergeUtils.mergeLists<Message>(
        current: _messages,
        incoming: incoming,
        prependNew: false,
      );

      merged.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      if (mounted) {
        bool isAtBottom =
            _scrollController.hasClients &&
            _scrollController.offset >=
                _scrollController.position.maxScrollExtent - 50;

        setState(() {
          _messages = merged;
        });

        if (force || isAtBottom) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom(),
          );
        }
      }
    } catch (e) {
      print("Chat polling error: $e");
    } finally {
      _isFetching = false;
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    final successMsg = await _repo.sendMessage(widget.partner.id, text);

    if (successMsg != null) {
      _fetchMessages(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme Checks
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark
        ? DesignTokens.textSecondaryDark
        : DesignTokens.textSecondary;
    final inputBackgroundColor = isDark
        ? Colors.black.withOpacity(0.5)
        : DesignTokens.glassWhite.withOpacity(0.8);
    final inputBorderColor = isDark
        ? DesignTokens.glassBorderDark
        : DesignTokens.glassBorder;
    final typingTextColor = isDark
        ? DesignTokens.textPrimaryDark
        : DesignTokens.textPrimary;

    return GlassScaffold(
      showBottomNav: false,
      body: Column(
        children: [
          TopNav(title: widget.partner.displayName, showBack: true),

          // MESSAGE LIST
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      "No messages yet.\nSay hi! 👋",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: secondaryTextColor),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg.sender.id == _currentUserId;
                      return MessageBubble(message: msg, isMe: isMe);
                    },
                  ),
          ),

          // INPUT AREA
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: inputBackgroundColor,
              border: Border(top: BorderSide(color: inputBorderColor)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _textController,
                        style: TextStyle(
                          color: typingTextColor,
                        ), // Dynamic Text
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          hintStyle: TextStyle(
                            color: secondaryTextColor,
                          ), // Dynamic Hint
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _handleSend(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: DesignTokens.accentPrimary,
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _handleSend,
                    ),
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

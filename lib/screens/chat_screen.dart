// lib/screens/chat_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../data/chat_repository.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/glass_card.dart';
import '../widgets/cached_base64_image.dart';
import '../theme/design_tokens.dart';
import '../services/auth_service.dart';
import '../utils/time_formatter.dart';

class ChatScreen extends StatefulWidget {
  final User partner;

  const ChatScreen({super.key, required this.partner});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatRepository _repository = ChatRepository();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  List<Message> _localMessages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _currentUserId;
  Timer? _pollTimer;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _currentUserId = AuthService().currentUser?.id;
    _loadMessages();

    // Poll for new messages
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _loadMessages(isPolling: true);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({bool isPolling = false}) async {
    try {
      final msgs = await _repository.getMessages(widget.partner.id);

      if (mounted) {
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
          if (shouldUpdate) _scrollToBottom();
        }
      }
    } catch (e) {
      if (!isPolling && mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    setState(() => _isSending = true);

    // 1. Optimistic Update
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
      _textController.clear();
    });
    _scrollToBottom();

    // 2. Network Request
    await _repository.sendMessage(
      widget.partner.id,
      text,
      imageFile: _selectedImage,
    );

    // 3. Reset & Refresh
    if (mounted) {
      setState(() {
        _isSending = false;
        _selectedImage = null;
      });
      _loadMessages(isPolling: true);
    }
  }

  /// Opens the full-screen media viewer
  void _openMediaViewer(Message startMessage) {
    // Filter out only messages that have media
    final mediaMessages = _localMessages
        .where((m) => m.mediaId != null)
        .toList();

    // Find the index of the clicked message within the media-only list
    final initialIndex = mediaMessages.indexOf(startMessage);

    if (initialIndex != -1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MediaViewerScreen(
            mediaMessages: mediaMessages,
            initialIndex: initialIndex,
          ),
        ),
      );
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
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _localMessages.length,
                    itemBuilder: (context, index) {
                      final msg = _localMessages[index];
                      final isMe = msg.sender.id == _currentUserId;
                      return _buildMessageBubble(msg, isMe);
                    },
                  ),
          ),

          // --- Attachment Preview ---
          if (_selectedImage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Image selected",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => setState(() => _selectedImage = null),
                  ),
                ],
              ),
            ),

          // --- Input Bar ---
          Padding(
            padding: const EdgeInsets.all(DesignTokens.paddingMedium),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.add_photo_alternate,
                      color: _selectedImage != null
                          ? DesignTokens.accentPrimary
                          : DesignTokens.textSecondary,
                    ),
                    onPressed: _isSending ? null : _pickImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  _isSending
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
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

  Widget _buildMessageBubble(Message msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? DesignTokens.accentPrimary : DesignTokens.glassWhite,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 1. Media Image with Tap Handler
            if (msg.mediaId != null)
              GestureDetector(
                onTap: () => _openMediaViewer(msg),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Hero(
                    tag: 'media_${msg.mediaId}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedBase64Image(
                        mediaId: msg.mediaId!,
                        height: 150,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

            // 2. Text Content
            if (msg.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  msg.text,
                  style: TextStyle(
                    color: isMe ? Colors.white : DesignTokens.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),

            // 3. Timestamp
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 4),
              child: Text(
                TimeFormatter.formatChatTime(msg.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: isMe
                      ? Colors.white.withOpacity(0.7)
                      : DesignTokens.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- New Media Viewer Class ---

class MediaViewerScreen extends StatefulWidget {
  final List<Message> mediaMessages;
  final int initialIndex;

  const MediaViewerScreen({
    super.key,
    required this.mediaMessages,
    required this.initialIndex,
  });

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.mediaMessages[_currentIndex].sender.displayName,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              TimeFormatter.formatChatTime(
                widget.mediaMessages[_currentIndex].timestamp,
              ),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Image Slider
          PageView.builder(
            controller: _pageController,
            itemCount: widget.mediaMessages.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final msg = widget.mediaMessages[index];
              return Center(
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Hero(
                    tag: 'media_${msg.mediaId}',
                    child: CachedBase64Image(
                      mediaId: msg.mediaId!,
                      // Passing null/large dimensions to ensure full quality in viewer
                      // assuming widget handles fit nicely or defaults to containment
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ),
                  ),
                ),
              );
            },
          ),

          // Caption Overlay (WhatsApp style)
          if (widget.mediaMessages[_currentIndex].text.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.6),
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  top: false,
                  child: Text(
                    widget.mediaMessages[_currentIndex].text,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

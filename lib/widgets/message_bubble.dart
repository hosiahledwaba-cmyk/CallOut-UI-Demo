// lib/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../theme/design_tokens.dart';
import 'shared_post_bubble.dart';
import 'cached_base64_image.dart';
import '../utils/time_formatter.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          // FIX: Replaced undefined getter with valid token
          color: isMe
              ? DesignTokens.accentPrimary.withOpacity(0.8)
              : DesignTokens.glassWhite,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
          border: Border.all(color: DesignTokens.glassBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- CONTENT SWITCHER ---
            _buildContent(context),

            const SizedBox(height: 4),

            // --- TIMESTAMP ---
            Text(
              TimeFormatter.formatTime(message.timestamp),
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
  }

  Widget _buildContent(BuildContext context) {
    switch (message.type) {
      case MessageType.post:
        if (message.sharedPost != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SharedPostBubble(post: message.sharedPost!, isMe: isMe),
              // If user added text with the share
              if (message.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  message.text,
                  style: TextStyle(
                    color: isMe ? Colors.white : DesignTokens.textPrimary,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          );
        } else {
          return const Text(
            "Shared Post (Unavailable)",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.white70,
            ),
          );
        }

      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.mediaId != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedBase64Image(
                  mediaId: message.mediaId!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            if (message.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message.text,
                style: TextStyle(
                  color: isMe ? Colors.white : DesignTokens.textPrimary,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        );

      case MessageType.text:
      default:
        return Text(
          message.text,
          style: TextStyle(
            color: isMe ? Colors.white : DesignTokens.textPrimary,
            fontSize: 16,
          ),
        );
    }
  }
}

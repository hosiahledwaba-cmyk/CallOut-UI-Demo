// lib/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../theme/design_tokens.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? DesignTokens.accentPrimary.withOpacity(0.9)
              : DesignTokens.glassWhite.withOpacity(0.6),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(DesignTokens.borderRadiusMedium),
            topRight: const Radius.circular(DesignTokens.borderRadiusMedium),
            bottomLeft: Radius.circular(
              isMe ? DesignTokens.borderRadiusMedium : 0,
            ),
            bottomRight: Radius.circular(
              isMe ? 0 : DesignTokens.borderRadiusMedium,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isMe ? Colors.white : DesignTokens.textPrimary,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

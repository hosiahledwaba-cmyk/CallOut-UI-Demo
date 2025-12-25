// lib/widgets/avatar.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../theme/design_tokens.dart';

class Avatar extends StatelessWidget {
  final User user;
  final double radius;

  const Avatar({super.key, required this.user, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: DesignTokens.accentSecondary.withOpacity(0.2),
        backgroundImage: user.isAnonymous ? null : NetworkImage(user.avatarUrl),
        child: user.isAnonymous
            ? Icon(
                Icons.person_outline,
                color: DesignTokens.textSecondary,
                size: radius,
              )
            : null,
      ),
    );
  }
}

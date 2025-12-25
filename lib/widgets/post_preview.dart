// lib/widgets/post_preview.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/post.dart';
import 'glass_card.dart';
import 'avatar.dart';
import '../theme/design_tokens.dart';
import '../screens/post_detail_screen.dart';

class PostPreview extends StatelessWidget {
  final Post post;

  const PostPreview({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.paddingMedium),
      child: GlassCard(
        isAlert: post.isEmergency,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(post: post),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Avatar(user: post.author),
                const SizedBox(width: DesignTokens.paddingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.author.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (post.author.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              size: 14,
                              color: DesignTokens.accentSafe,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        "@${post.author.username} • 2h ago",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (post.isEmergency)
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: DesignTokens.accentAlert,
                  ),
              ],
            ),
            const SizedBox(height: DesignTokens.paddingMedium),
            Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
            if (post.imageUrl != null) ...[
              const SizedBox(height: DesignTokens.paddingMedium),
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  DesignTokens.borderRadiusSmall,
                ),
                child: Image.network(
                  post.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    height: 200,
                    color: Colors.white24,
                    child: const Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: DesignTokens.paddingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InteractionButton(
                  icon: CupertinoIcons.heart,
                  label: "${post.likes}",
                ),
                _InteractionButton(
                  icon: CupertinoIcons.chat_bubble,
                  label: "${post.comments}",
                ),
                const _InteractionButton(
                  icon: CupertinoIcons.share,
                  label: "Share",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InteractionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: DesignTokens.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

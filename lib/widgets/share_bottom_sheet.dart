// lib/widgets/share_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Needed for AppStateNotifier
import '../models/user.dart';
import '../models/post.dart';
import '../theme/design_tokens.dart';
import '../widgets/glass_card.dart';
import '../widgets/avatar.dart';
import '../data/profile_repository.dart';
import '../data/feed_repository.dart';
import '../data/chat_repository.dart'; // New Import
import '../state/app_state_notifier.dart'; // New Import

class ShareBottomSheet extends StatefulWidget {
  final Post post;

  const ShareBottomSheet({super.key, required this.post});

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  final ProfileRepository _profileRepo = ProfileRepository();
  final FeedRepository _feedRepo = FeedRepository();
  final ChatRepository _chatRepo = ChatRepository(); // For DMs

  List<User> _following = [];
  bool _isLoading = true;
  bool _isSending = false; // To prevent double taps

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  void _fetchContacts() async {
    // Fetch people I follow to suggest them for DM
    final users = await _profileRepo.getFollowing('me');
    if (mounted) {
      setState(() {
        _following = users;
        _isLoading = false;
      });
    }
  }

  // 1. HANDLE DM (Send Post Logic)
  void _handleDM(User user) async {
    if (_isSending) return;

    setState(() => _isSending = true);

    // We send the 'post.id'. The backend knows to embed the post object.
    final result = await _chatRepo.sendMessage(
      user.id,
      "", // Empty text is allowed for shared posts
      sharedPostId: widget.post.id,
    );

    if (!mounted) return;

    Navigator.pop(context); // Close sheet

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sent to ${user.displayName}"),
          backgroundColor: DesignTokens.accentSafe,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to send message"),
          backgroundColor: DesignTokens.accentAlert,
        ),
      );
    }
  }

  // 2. HANDLE REPOST (Feed Logic)
  void _handleRepost() async {
    Navigator.pop(context); // Close sheet immediately

    // Use the global notifier to perform the action and update the feed
    final success = await context.read<AppStateNotifier>().repostPost(
      widget.post.id,
    );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Reposted to your profile!"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not repost. Try again."),
            backgroundColor: DesignTokens.accentAlert,
          ),
        );
      }
    }
  }

  // 3. HANDLE EXTERNAL SHARE
  void _handleExternalShare() {
    Navigator.pop(context);
    _feedRepo.sharePostExternally(widget.post);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: DesignTokens.glassBorder, width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // DM SECTION HEADER
            const Text(
              "Send to...",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),

            // DM HORIZONTAL LIST
            SizedBox(
              height: 100,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: DesignTokens.accentPrimary,
                      ),
                    )
                  : _following.isEmpty
                  ? const Center(
                      child: Text(
                        "Follow people to message them",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _following.length,
                      itemBuilder: (context, index) {
                        final user = _following[index];
                        return GestureDetector(
                          onTap: () => _handleDM(user),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Avatar(user: user, radius: 28),
                                    if (_isSending)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    user.displayName.split(' ')[0],
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const Divider(color: Colors.grey),
            const SizedBox(height: 8),

            // ACTIONS LIST
            ListTile(
              leading: const Icon(
                Icons.repeat,
                color: DesignTokens.accentPrimary,
              ),
              title: const Text(
                "Repost",
                style: TextStyle(color: Colors.white),
              ),
              onTap: _handleRepost,
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text(
                "Share via...",
                style: TextStyle(color: Colors.white),
              ),
              onTap: _handleExternalShare,
            ),
            ListTile(
              leading: const Icon(Icons.link, color: Colors.white),
              title: const Text(
                "Copy Link",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // Same logic as external share, but maybe just copy to clipboard
                // For now, trigger standard share
                _handleExternalShare();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

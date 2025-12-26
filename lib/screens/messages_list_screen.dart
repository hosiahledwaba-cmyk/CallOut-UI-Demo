// lib/screens/messages_list_screen.dart
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/top_nav.dart';
import '../widgets/glass_card.dart';
import '../widgets/avatar.dart';
import '../data/chat_repository.dart';
import '../models/user.dart';
import '../theme/design_tokens.dart';
import 'chat_screen.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({super.key});

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  final ChatRepository _repository = ChatRepository();
  late Future<List<User>> _chatsFuture;

  @override
  void initState() {
    super.initState();
    _chatsFuture = _repository.getActiveChats();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      currentTabIndex: 2,
      body: Column(
        children: [
          const TopNav(title: "Messages"),
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _chatsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final chats = snapshot.data ?? [];

                if (chats.isEmpty) {
                  return const Center(child: Text("No active chats"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(DesignTokens.paddingMedium),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final user = chats[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: GlassCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(partner: user),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Avatar(user: user, radius: 24),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Text(
                                  "Tap to view conversation",
                                  style: TextStyle(
                                    color: DesignTokens.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// lib/models/user.dart
class User {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl; // Use local asset path or network url
  final bool isVerified;
  final bool isAnonymous;

  const User({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    this.isVerified = false,
    this.isAnonymous = false,
  });

  static const User anonymous = User(
    id: 'anon',
    username: 'anonymous',
    displayName: 'Anonymous User',
    avatarUrl: 'assets/anon.png', // Mock
    isAnonymous: true,
  );
}

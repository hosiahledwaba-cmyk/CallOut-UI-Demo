// lib/models/user.dart
class User {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
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
    avatarUrl: 'assets/anon.png',
    isAnonymous: true,
  );

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? 'unknown',
      displayName: json['display_name'] ?? 'Unknown User',
      avatarUrl: json['avatar_url'] ?? '',
      isVerified: json['is_verified'] ?? false,
      isAnonymous: json['is_anonymous'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
      'is_anonymous': isAnonymous,
    };
  }
}

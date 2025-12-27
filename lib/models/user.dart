// lib/models/user.dart
class User {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final bool isVerified;
  final bool isActivist;
  final bool isAnonymous;
  final bool isFollowing; // New field

  const User({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    this.isVerified = false,
    this.isActivist = false,
    this.isAnonymous = false,
    this.isFollowing = false, // Default
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
      displayName: json['display_name'] ?? json['username'] ?? 'User',
      avatarUrl: json['avatar_url'] ?? '',
      isVerified: json['is_verified'] ?? false,
      isActivist: json['is_activist'] ?? false,
      isAnonymous: json['is_anonymous'] ?? false,
      isFollowing: json['is_following'] ?? false,
    );
  }

  // CopyWith for optimistic updates
  User copyWith({bool? isFollowing}) {
    return User(
      id: id,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      isVerified: isVerified,
      isActivist: isActivist,
      isAnonymous: isAnonymous,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
      'is_activist': isActivist,
      'is_anonymous': isAnonymous,
      'is_following': isFollowing,
    };
  }
}

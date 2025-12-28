// lib/data/profile_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../services/auth_service.dart';

class ProfileRepository {
  // GET PROFILE
  Future<User> getUserProfile(String userId) async {
    // 1. Check if "Me"
    final currentUserId = AuthService().currentUser?.id;
    if (userId == 'me' || (currentUserId != null && userId == currentUserId)) {
      return _fetchMyProfile();
    }

    // 2. Try API
    try {
      final url = ApiConfig.userProfile.replaceAll('{id}', userId);
      final response = await http
          .get(Uri.parse(url), headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed');
    } catch (e) {
      // 3. Mock Fallback
      await Future.delayed(const Duration(milliseconds: 400));
      return User(
        id: userId,
        username: 'user_$userId',
        displayName: _getMockName(userId),
        avatarUrl: 'https://i.pravatar.cc/150?u=$userId',
        isVerified: userId.hashCode % 2 == 0,
        isActivist: userId.hashCode % 3 == 0,
        // Randomly assign "following" status for demo
        isFollowing: false,
      );
    }
  }

  Future<User> _fetchMyProfile() async {
    try {
      // This will now include "Authorization": "Bearer <user_id>"
      final response = await http
          .get(Uri.parse(ApiConfig.profile), headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed');
    } catch (e) {
      // Fallback only if API fails
      return AuthService().currentUser ??
          const User(
            id: 'me',
            username: 'me',
            displayName: 'Me',
            avatarUrl: '',
          );
    }
  }

  // GET USER POSTS
  Future<List<Post>> getUserPosts(String userId) async {
    try {
      final url = ApiConfig.userPosts.replaceAll('{id}', userId);
      final response = await http
          .get(Uri.parse(url), headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => Post.fromJson(e)).toList();
      }
      throw Exception('Failed');
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _getMockUserPosts(userId);
    }
  }

  // FOLLOW ACTION
  Future<bool> toggleFollow(String userId, bool isFollowing) async {
    try {
      final url = ApiConfig.userFollow.replaceAll('{id}', userId);
      final response = isFollowing
          ? await http
                .delete(Uri.parse(url), headers: ApiConfig.headers)
                .timeout(ApiConfig.timeout)
          : await http
                .post(Uri.parse(url), headers: ApiConfig.headers)
                .timeout(ApiConfig.timeout);
      return response.statusCode == 200;
    } catch (e) {
      return true; // Optimistic success
    }
  }

  // --- HELPERS ---
  String _getMockName(String id) {
    if (id.contains('sarah')) return 'Sarah Jenkins';
    if (id.contains('safe')) return 'Safe Zone NGO';
    if (id.contains('emily')) return 'Dr. Emily';
    return 'Community Member';
  }

  List<Post> _getMockUserPosts(String userId) {
    // Return empty list for random users to test empty state, or populate for specific ones
    final user = User(
      id: userId,
      username: 'user',
      displayName: _getMockName(userId),
      avatarUrl: '',
    );

    return [
      Post(
        id: 'p1_$userId',
        author: user,
        content:
            "We are organizing a neighborhood watch meeting this Friday. DM for details.",
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        likes: 42,
        comments: 5,
      ),
      Post(
        id: 'p2_$userId',
        author: user,
        content:
            "Safety Tip: Always share your live location with a trusted contact when traveling late.",
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        likes: 156,
        comments: 12,
      ),
      Post(
        id: 'p3_$userId',
        author: user,
        content:
            "Just verified my profile! Happy to be part of this safe space.",
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        likes: 89,
        comments: 22,
      ),
    ];
  }
}

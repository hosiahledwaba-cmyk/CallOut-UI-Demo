// lib/data/profile_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../services/auth_service.dart';

class ProfileRepository {
  // GET PROFILE (Generic)
  Future<User> getUserProfile(String userId) async {
    // Special case for "me"
    if (userId == 'me' || userId == AuthService().currentUser?.id) {
      return _fetchMyProfile();
    }

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
      // Mock Data
      await Future.delayed(const Duration(milliseconds: 500));
      return User(
        id: userId,
        username: 'mock_user',
        displayName: 'Mock User',
        avatarUrl: 'https://i.pravatar.cc/150?u=$userId',
        isVerified: userId.hashCode % 2 == 0,
        isActivist: userId.hashCode % 3 == 0,
      );
    }
  }

  Future<User> _fetchMyProfile() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.profile), headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed');
    } catch (e) {
      // Return cached/local user
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
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockUserPosts(userId);
    }
  }

  // FOLLOW/UNFOLLOW
  Future<bool> toggleFollow(String userId, bool isFollowing) async {
    final url = ApiConfig.userFollow.replaceAll('{id}', userId);
    try {
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

  // Mock Posts Generator
  List<Post> _getMockUserPosts(String userId) {
    final author = User(
      id: userId,
      username: 'user_$userId',
      displayName: 'User',
      avatarUrl: '',
    );
    return [
      Post(
        id: 'p1_$userId',
        author: author,
        content: "Advocating for change in our community.",
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        likes: 24,
        comments: 5,
      ),
      Post(
        id: 'p2_$userId',
        author: author,
        content: "Stay safe everyone.",
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        likes: 12,
        comments: 0,
      ),
    ];
  }
}

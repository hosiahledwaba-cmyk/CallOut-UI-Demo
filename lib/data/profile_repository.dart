// lib/data/profile_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../services/auth_service.dart';

class ProfileRepository {
  Future<User?> getUserProfile(String userId) async {
    final currentUserId = AuthService().currentUser?.id;

    String url;
    if (userId == 'me' || (currentUserId != null && userId == currentUserId)) {
      url = ApiConfig.profile;
    } else {
      url = ApiConfig.userProfile.replaceAll('{id}', userId);
    }

    try {
      final response = await http
          .get(Uri.parse(url), headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        print(
          "❌ Profile Fetch Failed: ${response.statusCode} - ${response.body}",
        );
        return null;
      }
    } catch (e) {
      print("❌ Profile Error: $e");
      return null;
    }
  }

  Future<List<Post>> getUserPosts(String userId) async {
    String targetId = userId;
    if (userId == 'me') {
      targetId = "me";
    }

    try {
      final url = ApiConfig.userPosts.replaceAll('{id}', targetId);
      final response = await http
          .get(Uri.parse(url), headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => Post.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("❌ User Posts Error: $e");
      return [];
    }
  }

  Future<bool> toggleFollow(String userId, bool isFollowing) async {
    try {
      final url = ApiConfig.userFollow.replaceAll('{id}', userId);
      final response = isFollowing
          ? await http.delete(Uri.parse(url), headers: ApiConfig.headers)
          : await http.post(Uri.parse(url), headers: ApiConfig.headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<User>> getFollowers(String userId) async {
    return _fetchUserList(userId, "followers");
  }

  Future<List<User>> getFollowing(String userId) async {
    return _fetchUserList(userId, "following");
  }

  // Helper to avoid duplicate code
  Future<List<User>> _fetchUserList(String userId, String endpoint) async {
    String targetId = userId;
    if (userId == 'me') {
      final me = AuthService().currentUser?.id;
      if (me != null) targetId = me;
    }

    try {
      // /users/{id}/followers OR /users/{id}/following
      final url = "${ApiConfig.users}/$targetId/$endpoint";

      final response = await http
          .get(Uri.parse(url), headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => User.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("❌ Fetch $endpoint error: $e");
      return [];
    }
  }
}

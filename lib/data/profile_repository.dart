// lib/data/profile_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../models/user.dart';

class ProfileRepository {
  Future<User> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.profile),
        headers: ApiConfig.headers,
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed');
    } catch (e) {
      return const User(
        id: 'me',
        username: 'jane_doe',
        displayName: 'Jane Doe',
        avatarUrl: 'https://i.pravatar.cc/150?u=99',
      );
    }
  }

  Future<Map<String, String>> getUserStats() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.profile}/stats"),
        headers: ApiConfig.headers,
      );
      if (response.statusCode == 200) {
        return Map<String, String>.from(jsonDecode(response.body));
      }
      throw Exception('Failed');
    } catch (e) {
      return {"posts": "12", "following": "340", "followers": "120"};
    }
  }
}

// lib/data/search_repository.dart
import 'dart:convert';
import 'dart:async'; // Import for TimeoutException
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../models/resource.dart';
import '../models/user.dart';
import '../models/post.dart';

class SearchRepository {
  static const double centerLat = 51.509865;
  static const double centerLng = -0.118092;

  // --- EXISTING RESOURCE LOGIC ---
  Future<List<Resource>> getNearbyResources() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.resources), headers: ApiConfig.headers)
          .timeout(const Duration(seconds: 2)); // FIX: Fail fast if no backend

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => Resource.fromJson(e)).toList();
      }
      throw Exception('Failed');
    } catch (e) {
      // Fallback: Mock Data
      return _getMockResources();
    }
  }

  // Separated mock data for clarity
  List<Resource> _getMockResources() {
    return [
      const Resource(
        id: 'r1',
        name: "St. Mary's Women's Clinic",
        description: "24/7 trauma care and counseling.",
        distance: "0.8 km",
        category: ResourceCategory.medical,
        phoneNumber: "111-222-3333",
        latitude: centerLat + 0.002,
        longitude: centerLng + 0.002,
        isOpenNow: true,
      ),
      const Resource(
        id: 'r2',
        name: "Central Police Station",
        description: "Special Victims Unit.",
        distance: "1.2 km",
        category: ResourceCategory.police,
        phoneNumber: "911",
        latitude: centerLat - 0.003,
        longitude: centerLng + 0.001,
        isOpenNow: true,
      ),
      const Resource(
        id: 'r3',
        name: "Legal Aid Society",
        description: "Free legal representation.",
        distance: "3.1 km",
        category: ResourceCategory.legal,
        phoneNumber: "555-LAW",
        latitude: centerLat - 0.005,
        longitude: centerLng - 0.002,
        isOpenNow: false,
      ),
      const Resource(
        id: 'r4',
        name: "New Hope Shelter",
        description: "Emergency overnight shelter.",
        distance: "2.4 km",
        category: ResourceCategory.shelter,
        phoneNumber: "555-0199",
        latitude: centerLat + 0.001,
        longitude: centerLng - 0.004,
        isOpenNow: true,
      ),
    ];
  }

  // --- SOCIAL LOGIC (Kept same) ---
  Future<List<User>> searchUsers(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allUsers = [
      const User(
        id: 'u1',
        username: 'sarah_j',
        displayName: 'Sarah Jenkins',
        avatarUrl: 'https://i.pravatar.cc/150?u=1',
        isVerified: true,
      ),
      const User(
        id: 'u2',
        username: 'safe_zone',
        displayName: 'Safe Zone NGO',
        avatarUrl: 'https://i.pravatar.cc/150?u=2',
        isVerified: true,
      ),
      const User(
        id: 'u3',
        username: 'dr_emily',
        displayName: 'Dr. Emily',
        avatarUrl: 'https://i.pravatar.cc/150?u=3',
        isVerified: true,
      ),
      const User(
        id: 'u4',
        username: 'jane_doe',
        displayName: 'Jane Doe',
        avatarUrl: 'https://i.pravatar.cc/150?u=4',
      ),
    ];
    if (query.isEmpty) return allUsers;
    return allUsers
        .where(
          (u) =>
              u.displayName.toLowerCase().contains(query.toLowerCase()) ||
              u.username.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  Future<List<Post>> searchPosts(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final u1 = const User(
      id: 'u1',
      username: 'sarah_j',
      displayName: 'Sarah Jenkins',
      avatarUrl: 'https://i.pravatar.cc/150?u=1',
    );
    final allPosts = [
      Post(
        id: 'p1',
        author: u1,
        content: "The new laws on digital harassment are a game changer.",
        timestamp: DateTime.now(),
        likes: 45,
        comments: 12,
      ),
      Post(
        id: 'p2',
        author: User.anonymous,
        content: "Does anyone know where to find legal aid in District 9?",
        timestamp: DateTime.now(),
        likes: 12,
        comments: 4,
      ),
      Post(
        id: 'p3',
        author: u1,
        content: "#SafetyFirst tips for traveling alone at night.",
        timestamp: DateTime.now(),
        likes: 89,
        comments: 20,
      ),
    ];
    if (query.isEmpty) return allPosts;
    return allPosts
        .where((p) => p.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

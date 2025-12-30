// lib/data/api_config.dart
import '../services/auth_service.dart';

class ApiConfig {
  // 1. Set this to your actual backend URL when ready.
  static const String baseUrl =
      "https://serverless-api-test-iota.vercel.app/v1";

  // Auth
  static const String login = "$baseUrl/auth/login";
  static const String signup = "$baseUrl/auth/signup";

  // Feed
  static const String feed = "$baseUrl/feed";
  static const String posts = "$baseUrl/posts";
  static const String postLike = "$baseUrl/posts/{id}/like";
  static const String postComment = "$baseUrl/posts/{id}/comments";
  static const String postShare = "$baseUrl/posts/{id}/share";

  // --- MEDIA ENDPOINTS ---
  static const String media = "$baseUrl/media"; // POST
  static const String mediaDownload = "$baseUrl/media/{id}"; // GET

  // Users
  static const String users = "$baseUrl/users"; // GET list
  static const String userProfile =
      "$baseUrl/users/{id}"; // GET specific profile
  static const String userPosts =
      "$baseUrl/users/{id}/posts"; // GET user's posts
  static const String userFollow =
      "$baseUrl/users/{id}/follow"; // POST/DELETE follow
  static const String profile = "$baseUrl/profile"; // GET 'me'

  // --- NEW UPDATES FOR FOLLOWER LISTS ---
  static const String userFollowers =
      "$baseUrl/users/{id}/followers"; // GET list of followers
  static const String userFollowing =
      "$baseUrl/users/{id}/following"; // GET list of following

  // Chat
  static const String chats = "$baseUrl/chats"; // GET active convos
  static const String chatMessages =
      "$baseUrl/chats/{id}/messages"; // GET/POST messages

  // Misc
  static const String resources = "$baseUrl/resources";
  static const String searchUsers = "$baseUrl/search/users";
  static const String searchPosts = "$baseUrl/search/posts";
  static const String notifications = "$baseUrl/notifications";

  static Map<String, String> get headers {
    final baseHeaders = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    // Get latest token from AuthService
    final token = AuthService().token;

    if (token != null && token.isNotEmpty) {
      // Send BOTH standards to ensure backend compatibility
      baseHeaders["Authorization"] = "Bearer $token";
      baseHeaders["user_id"] = token;
    }

    return baseHeaders;
  }

  static const Duration timeout = Duration(seconds: 60);
}

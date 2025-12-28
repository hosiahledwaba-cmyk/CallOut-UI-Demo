// lib/data/api_config.dart
import '../services/auth_service.dart';

class ApiConfig {
  // 1. Set this to your actual backend URL when ready.
  // Leave it as is to force the app to use Mock Data (since this URL won't resolve).
  static const String baseUrl =
      "https://serverless-api-test-iota.vercel.app/v1"; // paste the url below here when ready:
  //  "https://serverless-api-test-iota.vercel.app/v1"
  // "http://10.0.2.2:8000/v1"

  // Auth
  static const String login = "$baseUrl/auth/login";
  static const String signup = "$baseUrl/auth/signup";

  // Feed
  static const String feed = "$baseUrl/feed";
  static const String posts = "$baseUrl/posts";
  static const String postLike = "$baseUrl/posts/{id}/like";
  static const String postComment = "$baseUrl/posts/{id}/comments";
  static const String postShare = "$baseUrl/posts/{id}/share";

  // --- MEDIA ENDPOINTS (Missing) ---
  static const String media = "$baseUrl/media"; // POST
  static const String mediaDownload = "$baseUrl/media/{id}"; // GET

  // Users
  static const String users = "$baseUrl/users"; // GET list
  static const String userProfile =
      "$baseUrl/users/{id}"; // GET specific profile
  static const String userPosts =
      "$baseUrl/users/{id}/posts"; // GET user's posts
  static const String userFollow = "$baseUrl/users/{id}/follow";
  static const String profile = "$baseUrl/profile"; // GET 'me'

  // Chat
  static const String chats = "$baseUrl/chats"; // GET active convos
  static const String chatMessages =
      "$baseUrl/chats/{id}/messages"; // GET/POST messages

  static const String resources = "$baseUrl/resources";
  static const String searchUsers = "$baseUrl/search/users";
  static const String searchPosts = "$baseUrl/search/posts";
  static const String notifications = "$baseUrl/notifications";

  static Map<String, String> get headers {
    final baseHeaders = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    // FIX: Get latest token from AuthService
    final token = AuthService().token;

    if (token != null && token.isNotEmpty) {
      // Send BOTH standards to ensure backend compatibility
      baseHeaders["Authorization"] = "Bearer $token";
      baseHeaders["user_id"] = token;
    }

    return baseHeaders;
  }

  static const Duration timeout = Duration(seconds: 19);
}

// lib/data/api_config.dart
class ApiConfig {
  // 1. Set this to your actual backend URL when ready.
  // Leave it as is to force the app to use Mock Data (since this URL won't resolve).
  static const String baseUrl = ""; // paste the url below here when ready:
  //  "https://serverless-api-test-iota.vercel.app/v1"

  // Auth
  static const String login = "$baseUrl/auth/login";
  static const String signup = "$baseUrl/auth/signup";

  // Feed
  static const String feed = "$baseUrl/feed";
  static const String posts = "$baseUrl/posts";
  static const String postLike = "$baseUrl/posts/{id}/like";
  static const String postComment = "$baseUrl/posts/{id}/comments";
  static const String postShare = "$baseUrl/posts/{id}/share";

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

  static Map<String, String> get headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  static const Duration timeout = Duration(seconds: 3);
}

// lib/data/api_config.dart
class ApiConfig {
  // 1. Set this to your actual backend URL when ready.
  // Leave it as is to force the app to use Mock Data (since this URL won't resolve).
  static const String baseUrl =
      "https://serverless-api-test-iota.vercel.app/v1";

  // 2. Endpoints
  static const String login = "$baseUrl/auth/login";
  static const String signup = "$baseUrl/auth/signup";
  static const String feed = "$baseUrl/feed";
  static const String posts = "$baseUrl/posts"; // GET for list, POST for create
  static const String chats = "$baseUrl/chats";
  static const String searchUsers = "$baseUrl/search/users";
  static const String searchPosts = "$baseUrl/search/posts";
  static const String resources = "$baseUrl/resources";
  static const String profile = "$baseUrl/profile";
  static const String notifications = "$baseUrl/notifications";

  // 3. Headers (Add your Auth Tokens here dynamically if needed)
  static Map<String, String> get headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
    // "Authorization": "Bearer $token",
  };

  // 4. Timeouts: How long to wait for API before switching to Mock data
  static const Duration timeout = Duration(seconds: 3);
}

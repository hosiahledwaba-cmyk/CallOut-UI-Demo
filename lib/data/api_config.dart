// lib/data/api_config.dart
class ApiConfig {
  // 1. Set this to your actual backend URL when ready.
  // Leave it as is to force the app to use Mock Data (since this URL won't resolve).
  static const String baseUrl = ""; // paste the url below here when ready:
  //  "https://serverless-api-test-iota.vercel.app/v1"

  // 2. Endpoints
  static const String login = "$baseUrl/auth/login";
  static const String signup = "$baseUrl/auth/signup";

  // Feed & Posts
  static const String feed = "$baseUrl/feed";
  static const String posts = "$baseUrl/posts"; // GET list, POST create
  static const String postLike =
      "$baseUrl/posts/{id}/like"; // POST to like, DELETE to unlike
  static const String postComment =
      "$baseUrl/posts/{id}/comments"; // POST comment
  static const String postShare = "$baseUrl/posts/{id}/share"; // POST share

  // Users & Profile
  static const String profile = "$baseUrl/profile";
  static const String userFollow =
      "$baseUrl/users/{id}/follow"; // POST follow, DELETE unfollow
  static const String notifications = "$baseUrl/notifications";

  // Search & Resources
  static const String chats = "$baseUrl/chats";
  static const String searchUsers = "$baseUrl/search/users";
  static const String searchPosts = "$baseUrl/search/posts";
  static const String resources = "$baseUrl/resources";

  // 3. Headers
  static Map<String, String> get headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  // 4. Timeouts
  static const Duration timeout = Duration(seconds: 3);
}

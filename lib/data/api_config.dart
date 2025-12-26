// lib/data/api_config.dart
class ApiConfig {
  // TODO: Replace with your actual backend URL
  static const String baseUrl = "https://api.yoursafespaceapp.com/v1";

  // Endpoints
  static const String feed = "$baseUrl/feed";
  static const String posts = "$baseUrl/posts";
  static const String chats = "$baseUrl/chats";
  static const String search = "$baseUrl/search";
  static const String resources = "$baseUrl/resources";
  static const String profile = "$baseUrl/profile";
  static const String notifications = "$baseUrl/notifications";

  static Map<String, String> get headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };
}

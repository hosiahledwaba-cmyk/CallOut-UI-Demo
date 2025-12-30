// lib/services/feed_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/api_config.dart';
import '../models/post.dart';

class FeedService {
  Future<List<Post>> fetchFeed() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.feed), headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => Post.fromJson(e)).toList();
      } else {
        print("❌ Feed Fetch Failed: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Feed Service Error: $e");
      return [];
    }
  }
}

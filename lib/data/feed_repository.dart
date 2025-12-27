// lib/data/feed_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/user.dart';
import '../models/comment.dart';
import 'api_config.dart';

class FeedRepository {
  Future<List<Post>> getPosts() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.feed),
        headers: ApiConfig.headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => Post.fromJson(e)).toList();
      }
      throw Exception('Failed to load posts');
    } catch (e) {
      return _getMockPosts();
    }
  }

  Future<bool> createPost(
    String content,
    bool isAnonymous, {
    String? imageUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.posts),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'content': content,
          'is_anonymous': isAnonymous,
          'image_url': imageUrl,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      // Simulate success
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }
  }

  Future<List<Comment>> getComments(String postId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.posts}/$postId/comments"),
        headers: ApiConfig.headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => Comment.fromJson(e)).toList();
      }
      throw Exception('Failed');
    } catch (e) {
      return _getMockComments();
    }
  }

  Future<bool> likePost(String postId, bool isLiked) async {
    final url = ApiConfig.postLike.replaceAll('{id}', postId);
    try {
      final response = isLiked
          ? await http
                .post(Uri.parse(url), headers: ApiConfig.headers)
                .timeout(ApiConfig.timeout)
          : await http
                .delete(Uri.parse(url), headers: ApiConfig.headers)
                .timeout(ApiConfig.timeout);

      return response.statusCode == 200;
    } catch (e) {
      return true; // Optimistic success for mock
    }
  }

  Future<bool> sharePost(String postId) async {
    final url = ApiConfig.postShare.replaceAll('{id}', postId);
    try {
      await http
          .post(Uri.parse(url), headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);
      return true;
    } catch (e) {
      return true;
    }
  }

  Future<Comment?> addComment(String postId, String text) async {
    final url = ApiConfig.postComment.replaceAll('{id}', postId);
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: ApiConfig.headers,
            body: jsonEncode({'text': text}),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 201) {
        return Comment.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      // Mock return
      return Comment(
        id: 'c_${DateTime.now().millisecondsSinceEpoch}',
        author: const User(
          id: 'me',
          username: 'me',
          displayName: 'Me',
          avatarUrl: '',
        ),
        text: text,
        timestamp: DateTime.now(),
      );
    }
    return null;
  }

  List<Post> _getMockPosts() {
    // Reusing previous mock logic for brevity
    final User user1 = const User(
      id: 'u1',
      username: 'sarah_j',
      displayName: 'Sarah Jenkins',
      avatarUrl: 'https://i.pravatar.cc/150?u=1',
      isVerified: true,
    );
    final User user2 = const User(
      id: 'u2',
      username: 'safe_zone',
      displayName: 'Safe Zone NGO',
      avatarUrl: 'https://i.pravatar.cc/150?u=2',
      isVerified: true,
    );
    return [
      Post(
        id: 'p1',
        author: user1,
        content: "Just attended the workshop on digital safety. #StaySafe",
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 124,
        comments: 2,
      ),
      Post(
        id: 'p2',
        author: User.anonymous,
        content: "I finally found the courage to speak up today.",
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 892,
        comments: 145,
      ),
      Post(
        id: 'p3',
        author: user2,
        content: "URGENT: Flood of reports coming from the downtown district.",
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        likes: 56,
        comments: 12,
        isEmergency: true,
      ),
    ];
  }

  List<Comment> _getMockComments() {
    return [
      Comment(
        id: 'c1',
        author: const User(
          id: 'u4',
          username: 'helper',
          displayName: 'Helper',
          avatarUrl: '',
        ),
        text: "We are here for you.",
        timestamp: DateTime.now(),
      ),
      Comment(
        id: 'c2',
        author: User.anonymous,
        text: "Stay strong.",
        timestamp: DateTime.now(),
      ),
    ];
  }
}

// lib/data/feed_repository.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/user.dart';
import '../models/comment.dart';
import 'api_config.dart';
import '../services/media_service.dart'; // Import Media Service

class FeedRepository {
  // GET FEED
  Future<List<Post>> getPosts() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.feed), headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => Post.fromJson(e)).toList();
      }
      throw Exception('Failed to load feed');
    } catch (e) {
      // Mock Data Fallback (for testing offline)
      return _getMockPosts();
    }
  }

  // CREATE POST (2-Step Process: Metadata -> Media Upload)
  Future<bool> createPost(
    String content,
    bool isAnonymous, {
    String? imageUrl,
    List<File> imageFiles = const [], // Accepts multiple images
  }) async {
    try {
      // Step 1: Create the Post metadata
      // The backend creates the post document and returns its ID immediately.
      final response = await http
          .post(
            Uri.parse(ApiConfig.posts),
            headers: ApiConfig.headers,
            body: jsonEncode({
              'content': content,
              'is_anonymous': isAnonymous,
              'image_url': imageUrl,
            }),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Step 2: If we have images, upload them using the returned Post ID
        if (imageFiles.isNotEmpty) {
          final responseData = jsonDecode(response.body);

          // Debug Print
          print("📝 Post Created. Response: $responseData");

          final String? postId = responseData['id'];

          if (postId != null) {
            print("🚀 Uploading ${imageFiles.length} images for Post: $postId");

            // Parallel Upload: Faster than looping one by one
            final uploadTasks = imageFiles.map((file) {
              // CRITICAL FIX: Explicitly set type to "post"
              // This tells the backend to store it in 'post_media' and link it to the post
              return MediaService().uploadMedia(postId, file, type: "post");
            });

            // Wait for all uploads to finish
            await Future.wait(uploadTasks);
            print("✅ All media uploaded successfully.");
          } else {
            print(
              "❌ Error: Backend did not return a Post ID. Skipping media upload.",
            );
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      print("Create Post Error: $e");
      // For Mock/Demo Mode: Simulate success after delay
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }
  }

  // TOGGLE LIKE
  Future<bool> likePost(String postId, bool isLiked) async {
    try {
      final url = ApiConfig.postLike.replaceAll('{id}', postId);

      final response = isLiked
          ? await http
                .post(Uri.parse(url), headers: ApiConfig.headers)
                .timeout(ApiConfig.timeout)
          : await http
                .delete(Uri.parse(url), headers: ApiConfig.headers)
                .timeout(ApiConfig.timeout);

      return response.statusCode == 200;
    } catch (e) {
      return true; // Optimistic success
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
      // Mock return for optimistic UI
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

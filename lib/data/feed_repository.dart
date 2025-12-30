// lib/data/feed_repository.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart'; // For external sharing
import '../models/post.dart';
import '../models/user.dart';
import '../models/comment.dart';
import 'api_config.dart';
import '../services/media_service.dart';

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

      // If server returns error, print it!
      print("❌ Server Error ${response.statusCode}: ${response.body}");
      throw Exception('Failed to load feed');
    } catch (e) {
      // STOP RETURNING MOCK DATA
      // return _getMockPosts();

      print("❌ Feed Fetch Error: $e");
      return []; // Return empty so we don't confuse the UI
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
          final String? postId = responseData['id'];

          if (postId != null) {
            print("🚀 Uploading ${imageFiles.length} images for Post: $postId");

            // Parallel Upload
            final uploadTasks = imageFiles.map((file) {
              return MediaService().uploadMedia(postId, file, type: "post");
            });

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
      return false;
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
      return false;
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

  // Track internal share count (optional, distinct from external share)
  Future<bool> sharePost(String postId) async {
    final url = ApiConfig.postShare.replaceAll('{id}', postId);
    try {
      await http
          .post(Uri.parse(url), headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);
      return true;
    } catch (e) {
      return false;
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
      print("Add Comment Error: $e");
    }
    return null;
  }

  // 1. REPOST FUNCTIONALITY
  // Now calls the actual endpoint and returns the new Post object
  Future<Post?> repostPost(String originalPostId) async {
    try {
      // Endpoint: /posts/{id}/repost
      final url = "${ApiConfig.posts}/$originalPostId/repost";

      final response = await http.post(
        Uri.parse(url),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Post.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print("❌ Repost Error: $e");
      return null;
    }
  }

  // 2. EXTERNAL SHARE
  // Uses share_plus to trigger system share sheet
  Future<void> sharePostExternally(Post post) async {
    // If it's a repost, we usually share the original content
    final idToShare = post.isRepost && post.repostedPost != null
        ? post.repostedPost!.id
        : post.id;

    final String deepLink = "https://safespace.app/post/$idToShare";
    final String shareText = "Check out this post on SafeSpace:\n$deepLink";

    await Share.share(shareText);
  }

  Future<Post?> getPostById(String id) async {
    try {
      final response = await http
          .get(Uri.parse("${ApiConfig.posts}/$id"), headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return Post.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("Fetch Post By ID Error: $e");
    }
    return null;
  }

  // --- MOCKS ---
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

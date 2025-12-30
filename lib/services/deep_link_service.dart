// lib/services/deep_link_service.dart
import 'dart:async';
import 'package:app_links/app_links.dart'; // The package we added
import 'package:flutter/material.dart';
import '../data/feed_repository.dart';
import '../screens/post_detail_screen.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  final FeedRepository _feedRepo = FeedRepository();
  StreamSubscription? _linkSubscription;

  // We need the Navigator Key to push screens without context
  GlobalKey<NavigatorState>? navigatorKey;

  void init(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
    _checkInitialLink();
    _listenForLinks();
  }

  // 1. Handle Cold Start (App was closed)
  Future<void> _checkInitialLink() async {
    try {
      final Uri? uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _handleDeepLink(uri);
      }
    } catch (e) {
      print("Deep Link Error: $e");
    }
  }

  // 2. Handle Background/Warm Start (App was minimized)
  void _listenForLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  // 3. The Logic
  Future<void> _handleDeepLink(Uri uri) async {
    print("🔗 Deep Link Received: $uri");

    // Expected format: https://safespace.app/post/{postId}
    if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'post') {
      final String postId = uri.pathSegments[1];

      // Fetch the post data
      final post = await _feedRepo.getPostById(postId);

      if (post != null && navigatorKey?.currentState != null) {
        // Navigate to the screen
        navigatorKey!.currentState!.push(
          MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
        );
      } else {
        print("❌ Could not fetch post or navigator not ready");
      }
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}

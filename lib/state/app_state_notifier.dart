// lib/state/app_state_notifier.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../data/feed_repository.dart';
import '../models/post.dart';

class AppStateNotifier extends ChangeNotifier with WidgetsBindingObserver {
  final FeedRepository _feedRepo = FeedRepository();
  Timer? _timer;

  List<Post> _feed = [];
  List<Post> get feed => _feed;

  bool _isRefreshing = false;
  bool _isPaused = false;

  AppStateNotifier() {
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
    refresh(force: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _isPaused = true;
      _stopTimer();
    } else if (state == AppLifecycleState.resumed) {
      _isPaused = false;
      _startTimer();
      refresh();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => refresh());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> refresh({bool force = false}) async {
    if ((_isRefreshing && !force) || _isPaused) return;

    _isRefreshing = true;

    try {
      final incomingPosts = await _feedRepo.getPosts();

      // --- FIXED MERGE LOGIC START ---

      // 1. Create a Map from the CURRENT feed (to keep existing data)
      final Map<String, Post> postMap = {for (var post in _feed) post.id: post};

      // 2. Update/Overwrite with NEW data from server
      for (var post in incomingPosts) {
        postMap[post.id] = post;
      }

      // 3. Convert back to a list
      final allPosts = postMap.values.toList();

      // 4. FORCE SORT: Newest (Future) -> Oldest (Past)
      // This ensures that even if data arrives out of order, it displays correctly.
      allPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // 5. Update State
      if (allPosts.length != _feed.length || _hasContentChanged(allPosts)) {
        _feed = allPosts;
        notifyListeners();
      }

      // --- FIXED MERGE LOGIC END ---
    } catch (e) {
      print("⚠️ Background refresh failed: $e");
    } finally {
      _isRefreshing = false;
    }
  }

  bool _hasContentChanged(List<Post> newFeed) {
    if (_feed.isEmpty) return true;
    if (newFeed.isEmpty) return false;
    return newFeed.first.id != _feed.first.id;
  }

  Future<bool> repostPost(String originalPostId) async {
    try {
      final newRepost = await _feedRepo.repostPost(originalPostId);
      if (newRepost != null) {
        // Insert at top locally
        _feed.insert(0, newRepost);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Repost logic failed: $e");
      return false;
    }
  }
}

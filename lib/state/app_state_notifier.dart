// lib/state/app_state_notifier.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../data/feed_repository.dart';
import '../models/post.dart';
import '../utils/merge_utils.dart';

class AppStateNotifier extends ChangeNotifier with WidgetsBindingObserver {
  final FeedRepository _feedRepo = FeedRepository();
  Timer? _timer;

  // GLOBAL STATE
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
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => refresh());
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

      if (incomingPosts.isEmpty) return;

      final mergedPosts = MergeUtils.mergeLists<Post>(
        current: _feed,
        incoming: incomingPosts,
        prependNew: true,
      );

      if (mergedPosts.length != _feed.length ||
          _hasContentChanged(mergedPosts)) {
        _feed = mergedPosts;
        notifyListeners();
      }
    } catch (e) {
      print("⚠️ Background refresh failed: $e");
    } finally {
      _isRefreshing = false;
    }
  }

  bool _hasContentChanged(List<Post> newFeed) {
    if (_feed.isEmpty) return true;
    return newFeed.first.id != _feed.first.id;
  }

  // --- NEW: REPOST ACTION ---
  Future<bool> repostPost(String originalPostId) async {
    try {
      // 1. Call API
      final newRepost = await _feedRepo.repostPost(originalPostId);

      if (newRepost != null) {
        // 2. Optimistic Update: Insert the new repost at the TOP of the feed
        // This makes it feel instant to the user.
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

// lib/state/app_state_notifier.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../data/feed_repository.dart'; // Uses your existing repo
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
    refresh(force: true); // Initial fetch
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
      // Use your existing repository method
      final incomingPosts = await _feedRepo.getPosts();

      if (incomingPosts.isEmpty) return;

      // Merge logic preserves scroll position
      final mergedPosts = MergeUtils.mergeLists<Post>(
        current: _feed,
        incoming: incomingPosts,
        prependNew: true,
      );

      // Only notify if data changed (simple ID check for top item)
      if (_feed.isEmpty ||
          mergedPosts.first.id != _feed.first.id ||
          mergedPosts.length != _feed.length) {
        _feed = mergedPosts;
        notifyListeners();
      } else {
        // Even if top ID didn't change, likes might have.
        // For production safety, we update anyway if counts differ,
        // or just update periodically. Here we update to be safe.
        _feed = mergedPosts;
        notifyListeners();
      }
    } catch (e) {
      print("⚠️ Background refresh failed: $e");
    } finally {
      _isRefreshing = false;
    }
  }
}

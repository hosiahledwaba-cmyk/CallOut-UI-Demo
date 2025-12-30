// lib/state/notification_state.dart
import 'package:flutter/material.dart';
import '../data/notification_repository.dart';
import '../models/notification_item.dart';

class NotificationState extends ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();
  List<NotificationItem> _items = [];
  bool _isLoading = false;

  List<NotificationItem> get items => _items;
  bool get isLoading => _isLoading;

  // Computed property for Red Dot (Badge)
  int get unreadCount => _items.where((n) => !n.isRead).length;

  NotificationState() {
    refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    final newItems = await _repo.getNotifications();
    _items = newItems;

    _isLoading = false;
    notifyListeners();
  }

  void markRead(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1 && !_items[index].isRead) {
      // 1. Optimistic Update (Update UI instantly)
      // Since NotificationItem is immutable (final), we replace it with a copy
      final oldItem = _items[index];
      _items[index] = NotificationItem(
        id: oldItem.id,
        sender: oldItem.sender,
        type: oldItem.type,
        referenceId: oldItem.referenceId,
        referenceText: oldItem.referenceText,
        createdAt: oldItem.createdAt,
        isRead: true, // <--- Change this
      );
      notifyListeners();

      // 2. Call Backend
      _repo.markAsRead(id);
    }
  }

  // --- THIS WAS MISSING ---
  Future<void> markAllRead() async {
    // 1. Optimistic Update: Mark all local items as read
    // We map over the list and set isRead = true for everyone
    _items = _items.map((item) {
      return NotificationItem(
        id: item.id,
        sender: item.sender,
        type: item.type,
        referenceId: item.referenceId,
        referenceText: item.referenceText,
        createdAt: item.createdAt,
        isRead: true,
      );
    }).toList();

    notifyListeners(); // Update UI immediately

    // 2. Call Backend
    await _repo.markAllRead();
  }
}

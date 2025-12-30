// lib/services/realtime_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app.dart'; // To access navigatorKey
import 'auth_service.dart';
import '../state/notification_state.dart';
import '../widgets/in_app_notification.dart';

class RealtimeService {
  // Singleton
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  StreamSubscription? _notifSubscription;

  // Initialize Listeners
  void init() {
    final user = AuthService().currentUser;
    if (user == null) return;

    print("🔌 Connecting to Real-time Notification Stream for ${user.id}...");

    // LISTEN TO NOTIFICATIONS
    _notifSubscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('recipient_id', isEqualTo: user.id)
        .where('is_read', isEqualTo: false) // Only active notifications
        .orderBy('created_at', descending: true)
        .limit(1) // We only care about the NEWEST one for popups
        .snapshots()
        .listen((snapshot) {
          // 1. Sync Badge Count (Global State)
          // We can do a separate count query or just increment locally,
          // but for now let's refresh the state provider.
          final context = navigatorKey.currentContext;
          if (context != null) {
            // This forces the "Red Dot" to update instantly across the app
            context.read<NotificationState>().refresh();
          }

          // 2. Trigger Pop-up
          // We check if this document was JUST added (to avoid popping up old stuff on app open)
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data();
              if (data != null) {
                _showInAppPopup(data);
              }
            }
          }
        });
  }

  void _showInAppPopup(Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Helper to format text based on type
    String title = "New Activity";
    String body = "You have a new notification.";
    final type = data['type'] ?? 'notification';
    final text = data['reference_text'] ?? '';

    if (type == 'like') {
      title = "New Like";
      body = "Someone liked your post.";
    } else if (type == 'comment') {
      title = "New Comment";
      body = "Someone commented: $text";
    } else if (type == 'follow') {
      title = "New Follower";
      body = "You have a new follower.";
    } else if (type == 'message') {
      title = "New Message";
      body = text;
    }

    // TRIGGER YOUR OVERLAY
    InAppNotificationOverlay.show(
      context,
      title: title,
      message: body,
      onTap: () {
        // TODO: Handle navigation based on 'reference_id'
        print("Tapped real-time notification: ${data['reference_id']}");
      },
    );
  }

  void dispose() {
    _notifSubscription?.cancel();
  }
}

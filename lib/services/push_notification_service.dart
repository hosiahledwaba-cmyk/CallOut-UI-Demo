// lib/services/push_notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:ui'; // For Color
import '../data/api_config.dart';
import 'auth_service.dart';
import '../app.dart'; // REQUIRED: To access 'navigatorKey'
import '../widgets/in_app_notification.dart'; // REQUIRED: For the overlay

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. Request Permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Push Permission Granted');

      // 2. Get Token & Sync
      String? token = await _fcm.getToken();
      if (token != null) {
        print("📲 Device Token: $token");
        _sendTokenToBackend(token);
      }

      // 3. Listen for Token Refreshes
      _fcm.onTokenRefresh.listen(_sendTokenToBackend);

      // 4. Setup Listeners (Foreground & Background)
      _setupForegroundListeners();
      _setupLocalNotifications();
    } else {
      print('❌ Push Permission Denied');
    }
  }

  void _setupForegroundListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Foreground Message: ${message.notification?.title}");

      if (message.notification != null) {
        // --- SHOW IN-APP OVERLAY ---
        final context = navigatorKey.currentContext;

        if (context != null) {
          InAppNotificationOverlay.show(
            context,
            title: message.notification!.title ?? 'New Notification',
            message: message.notification!.body ?? '',
            onTap: () {
              // TODO: Handle navigation based on message.data['type']
              print("Tapped notification!");
            },
          );
        } else {
          // Fallback if no context found (rare)
          _showSystemNotification(message);
        }
      }
    });
  }

  void _setupLocalNotifications() {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
    );

    _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  void _showSystemNotification(RemoteMessage message) {
    _localNotifications.show(
      message.notification.hashCode,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          color: Color(0xFF8E2DE2),
        ),
      ),
    );
  }

  Future<void> _sendTokenToBackend(String token) async {
    final user = AuthService().currentUser;
    if (user == null) return;

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/users/me/device-token"),
        headers: ApiConfig.headers,
        body: jsonEncode({
          "token": token,
          "platform": Platform.isAndroid ? "android" : "ios",
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Device Token saved to backend");
      } else {
        print("⚠️ Failed to save token: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error sending token: $e");
    }
  }
}

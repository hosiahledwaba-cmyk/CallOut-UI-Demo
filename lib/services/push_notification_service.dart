// lib/services/push_notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import '../data/api_config.dart';
import 'auth_service.dart';
import '../app.dart';
import '../widgets/in_app_notification.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. Setup Local Notifications (Android Icon)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // iOS Settings (Optional but recommended)
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        print("🔔 Tapped System Notification: ${response.payload}");
        // TODO: Handle navigation
      },
    );

    // 2. Create Channel IMMEDIATELY (Critical for Android Heads-up)
    await _createNotificationChannel();

    // 3. Request Permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Push Permission Granted');

      // 4. Sync Token
      String? token = await _fcm.getToken();
      if (token != null) {
        print("📲 Device Token: $token");
        _sendTokenToBackend(token);
      }

      // 5. Listeners
      _fcm.onTokenRefresh.listen(_sendTokenToBackend);
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    } else {
      print('❌ Push Permission Denied');
    }
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max, // IMPORTANCE_MAX shows heads-up
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print("📩 Foreground Message: ${message.notification?.title}");

    // 1. Try showing Custom In-App Overlay
    final context = navigatorKey.currentContext;
    if (context != null) {
      InAppNotificationOverlay.show(
        context,
        title: message.notification?.title ?? 'New Notification',
        message: message.notification?.body ?? '',
        onTap: () {},
      );
    } else {
      // 2. Fallback to System Notification if context is missing
      if (message.notification != null) {
        _showSystemNotification(message);
      }
    }
  }

  void _showSystemNotification(RemoteMessage message) {
    _localNotifications.show(
      message.hashCode,
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
      if (response.statusCode != 200) {
        print("⚠️ Failed to save token: ${response.body}");
      }
    } catch (e) {
      print("❌ Error sending token: $e");
    }
  }
}

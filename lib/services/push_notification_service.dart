// lib/services/push_notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../data/api_config.dart';
import 'auth_service.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 1. Request Permission (Critical for iOS, good practice for Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Push Permission Granted');

      // 2. Get the Device Token
      String? token = await _fcm.getToken();
      if (token != null) {
        print("📲 Device Token: $token");
        await _sendTokenToBackend(token);
      }

      // 3. Listen for Token Refreshes (Tokens change if app is reinstalled)
      _fcm.onTokenRefresh.listen(_sendTokenToBackend);
    } else {
      print('❌ Push Permission Denied');
    }
  }

  // 4. Send Token to Your Backend
  Future<void> _sendTokenToBackend(String token) async {
    final user = AuthService().currentUser;
    if (user == null) return; // Only save if logged in

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

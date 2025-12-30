// lib/data/notification_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../models/notification_item.dart';

class NotificationRepository {
  Future<List<NotificationItem>> getNotifications() async {
    try {
      final response = await http
          .get(
            Uri.parse("${ApiConfig.baseUrl}/notifications"),
            headers: ApiConfig.headers,
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => NotificationItem.fromJson(e)).toList();
      } else {
        print("❌ Notifications API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Notifications Network Error: $e");
    }
    // Return empty list on failure, do NOT return mocks
    return [];
  }

  Future<bool> markAsRead(String id) async {
    try {
      final response = await http.patch(
        Uri.parse("${ApiConfig.baseUrl}/notifications/$id/read"),
        headers: ApiConfig.headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Mark Read Error: $e");
      return false;
    }
  }

  Future<bool> markAllRead() async {
    try {
      final response = await http.patch(
        Uri.parse("${ApiConfig.baseUrl}/notifications/read-all"),
        headers: ApiConfig.headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

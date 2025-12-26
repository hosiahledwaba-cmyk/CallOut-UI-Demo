// lib/data/notification_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../models/notification_item.dart';

class NotificationRepository {
  Future<List<NotificationItem>> getNotifications() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.notifications), headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => NotificationItem.fromJson(e)).toList();
      }
      throw Exception('Failed');
    } catch (e) {
      return [
        NotificationItem(
          id: 'n1',
          message: "Safety Alert: Protest near City Center.",
          isUrgent: true,
          timestamp: DateTime.now(),
        ),
        NotificationItem(
          id: 'n2',
          message: "Sarah liked your post.",
          isUrgent: false,
          timestamp: DateTime.now(),
        ),
      ];
    }
  }
}

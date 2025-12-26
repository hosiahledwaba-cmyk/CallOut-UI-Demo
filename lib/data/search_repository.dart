// lib/data/search_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../models/resource.dart';

class SearchRepository {
  Future<List<String>> getSuggestedTopics() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.search}/topics"),
        headers: ApiConfig.headers,
      );
      if (response.statusCode == 200) {
        return List<String>.from(jsonDecode(response.body));
      }
      throw Exception('Failed');
    } catch (e) {
      return [
        "Legal Aid",
        "Counseling",
        "Shelters",
        "Self Defense",
        "Report Anonymous",
      ];
    }
  }

  Future<List<Resource>> getNearbyResources() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.resources),
        headers: ApiConfig.headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => Resource.fromJson(e)).toList();
      }
      throw Exception('Failed');
    } catch (e) {
      return [
        const Resource(
          id: 'r1',
          name: "Women's Clinic",
          distance: "2.4 km",
          type: 'medical',
        ),
        const Resource(
          id: 'r2',
          name: "Central Police Station",
          distance: "5.1 km",
          type: 'police',
        ),
        const Resource(
          id: 'r3',
          name: "Hope Foundation",
          distance: "1.2 km",
          type: 'ngo',
        ),
      ];
    }
  }
}

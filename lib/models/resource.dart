// lib/models/resource.dart
class Resource {
  final String id;
  final String name;
  final String description;
  final String distance;
  final ResourceCategory category;
  final String phoneNumber;
  final double latitude;
  final double longitude;
  final bool isOpenNow;

  const Resource({
    required this.id,
    required this.name,
    required this.description,
    required this.distance,
    required this.category,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
    this.isOpenNow = true,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      distance: json['distance'] ?? '',
      category: ResourceCategory.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'general'),
        orElse: () => ResourceCategory.general,
      ),
      phoneNumber: json['phone'] ?? '',
      latitude: json['lat'] ?? 0.0,
      longitude: json['lng'] ?? 0.0,
      isOpenNow: json['is_open'] ?? false,
    );
  }
}

enum ResourceCategory { police, medical, shelter, legal, counseling, general }

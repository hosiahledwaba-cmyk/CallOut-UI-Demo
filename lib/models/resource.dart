// lib/models/resource.dart
class Resource {
  final String id;
  final String name;
  final String distance;
  final String type; // e.g., 'shelter', 'police', 'clinic'

  const Resource({
    required this.id,
    required this.name,
    required this.distance,
    required this.type,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      distance: json['distance'] ?? '',
      type: json['type'] ?? 'general',
    );
  }
}

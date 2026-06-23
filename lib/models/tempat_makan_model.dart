class TempatMakanModel {
  final int id;
  final int userId;
  final String name;
  final String description;
  final String address;
  final double rating;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final String? mapsUrl;

  TempatMakanModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.address,
    required this.rating,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.mapsUrl,
  });

  factory TempatMakanModel.fromJson(Map<String, dynamic> json) {
    double? safeDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    return TempatMakanModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      rating: safeDouble(json['rating']) ?? 0.0,
      latitude: safeDouble(json['latitude']),
      longitude: safeDouble(json['longitude']),
      imageUrl: json['image_url'],
      mapsUrl: json['maps_url'],
    );
  }
}

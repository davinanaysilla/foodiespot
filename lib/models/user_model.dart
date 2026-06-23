class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String photoUrl;
  final bool isSuspended;
  final int reviewsCount;
  final int photosCount;
  final int favoritesCount;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone = '',
    this.photoUrl = '',
    this.isSuspended = false,
    this.reviewsCount = 0,
    this.photosCount = 0,
    this.favoritesCount = 0,
  });

  // Convert dari JSON Laravel ke Objek Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      phone: json['phone'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      isSuspended: json['is_suspended'] ?? false,
      reviewsCount: json['reviews_count'] ?? 0,
      photosCount: json['photos_count'] ?? 0,
      favoritesCount: json['favorites_count'] ?? 0,
    );
  }
}

class ReviewModel {
  final int id;
  final int userId;
  final int tempatMakanId;
  final int rating;
  final String comment;
  final String userName;
  final String?
      userPhotoUrl; // Foto profil reviewer (sudah full URL dari backend)
  final String? imageUrl; // Foto review (sudah full URL dari backend)
  final String? reply;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.tempatMakanId,
    required this.rating,
    required this.comment,
    required this.userName,
    this.userPhotoUrl,
    this.imageUrl,
    this.reply,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Safe int parse: handles both int and String from JSON
    int safeInt(dynamic val, [int fallback = 0]) {
      if (val == null) return fallback;
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? fallback;
      return fallback;
    }

    return ReviewModel(
      id: safeInt(json['id']),
      userId: safeInt(json['user_id']),
      tempatMakanId: safeInt(json['tempat_makan_id']),
      rating: safeInt(json['rating']),
      comment: json['comment'] ?? '',
      // Ambil nama dan foto profil reviewer dari relasi 'user'
      userName: json['user'] != null ? json['user']['name'] ?? 'User' : 'User',
      userPhotoUrl: json['user'] != null ? json['user']['photo_url'] : null,
      // Backend sudah return full URL di image_url
      imageUrl: json['image_url'],
      reply: json['reply'],
    );
  }
}

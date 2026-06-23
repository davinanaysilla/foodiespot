class ReviewModel {
  final int id;
  final int userId;
  final int tempatMakanId;
  final int rating;
  final String comment;
  final String userName;
  final String? userPhotoUrl;
  final String? imageUrl;
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
      userName: json['user'] != null ? json['user']['name'] ?? 'User' : 'User',
      userPhotoUrl: json['user'] != null ? json['user']['photo_url'] : null,
      imageUrl: json['image_url'],
      reply: json['reply'],
    );
  }

  ReviewModel copyWith({
    int? id,
    int? userId,
    int? tempatMakanId,
    int? rating,
    String? comment,
    String? userName,
    String? userPhotoUrl,
    String? imageUrl,
    String? reply,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tempatMakanId: tempatMakanId ?? this.tempatMakanId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      reply: reply ?? this.reply,
    );
  }
}

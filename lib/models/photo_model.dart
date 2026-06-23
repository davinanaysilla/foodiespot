class PhotoModel {
  final int id;
  final int userId;
  final int tempatMakanId;
  final String imageUrl;
  final String uploaderName;

  PhotoModel({
    required this.id,
    required this.userId,
    required this.tempatMakanId,
    required this.imageUrl,
    required this.uploaderName,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      tempatMakanId: json['tempat_makan_id'] ?? 0,
      imageUrl: json['image_url'] ?? json['image_path'] ?? '',
      uploaderName: json['user'] != null ? json['user']['name'] ?? 'User' : 'User',
    );
  }
}

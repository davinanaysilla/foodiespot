class PengajuanOwnerModel {
  final int id;
  final int userId;
  final String namaToko;
  final String deskripsiToko;
  final String? alamat;
  final String? ktpPath;
  final String status;
  final String? userName;
  final String? userEmail;

  PengajuanOwnerModel({
    required this.id,
    required this.userId,
    required this.namaToko,
    required this.deskripsiToko,
    this.alamat,
    this.ktpPath,
    required this.status,
    this.userName,
    this.userEmail,
  });

  factory PengajuanOwnerModel.fromJson(Map<String, dynamic> json) {
    return PengajuanOwnerModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      namaToko: json['nama_toko'] ?? '',
      deskripsiToko: json['deskripsi_toko'] ?? '',
      alamat: json['alamat'],
      ktpPath: json['ktp_path'],
      status: json['status'] ?? 'pending',
      userName: json['user'] != null ? json['user']['name'] : 'User Tidak Diketahui',
      userEmail: json['user'] != null ? json['user']['email'] : '-',
    );
  }
}

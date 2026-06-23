// =================== MODELS ===================

class UserModel {
  final String id;
  String name;
  String email;
  String phone;
  final String joinDate;
  String? avatar;
  final String role;
  String status; // 'aktif', 'banned'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.joinDate,
    this.avatar,
    required this.role,
    this.status = 'aktif',
  });
}

class RestaurantModel {
  String id;
  String name;
  String category;
  double rating;
  int reviewCount;
  String address;
  String phone;
  String openHours;
  String distance;
  String priceRange;
  String imageUrl;
  String description;
  bool isOpen;
  bool isFavorited;
  // Field tambahan untuk owner
  int monthlyVisitors;
  int favoriteCount;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.address,
    required this.phone,
    required this.openHours,
    required this.distance,
    required this.priceRange,
    required this.imageUrl,
    required this.description,
    required this.isOpen,
    this.isFavorited = false,
    this.monthlyVisitors = 0,
    this.favoriteCount = 0,
  });

  RestaurantModel copyWith({
    String? name,
    String? category,
    String? address,
    String? phone,
    String? openHours,
    String? distance,
    String? priceRange,
    String? imageUrl,
    String? description,
    bool? isOpen,
    bool? isFavorited,
    double? rating,
    int? reviewCount,
    int? monthlyVisitors,
    int? favoriteCount,
  }) {
    return RestaurantModel(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      openHours: openHours ?? this.openHours,
      distance: distance ?? this.distance,
      priceRange: priceRange ?? this.priceRange,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isOpen: isOpen ?? this.isOpen,
      isFavorited: isFavorited ?? this.isFavorited,
      monthlyVisitors: monthlyVisitors ?? this.monthlyVisitors,
      favoriteCount: favoriteCount ?? this.favoriteCount,
    );
  }
}

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String restaurantId;
  final String restaurantName;
  final double rating;
  final String comment;
  final String date;
  final List<String> photos;
  String? ownerReply;
  String? replyDate;
  bool isFlagged;           // untuk admin
  bool isPhotoReported;     // foto dilaporkan owner
  bool isReviewReported;    // review dilaporkan owner
  String? reportReason;     // alasan laporan review

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.restaurantId,
    this.restaurantName = '',
    required this.rating,
    required this.comment,
    required this.date,
    this.photos = const [],
    this.ownerReply,
    this.replyDate,
    this.isFlagged = false,
    this.isPhotoReported = false,
    this.isReviewReported = false,
    this.reportReason,
  });

  ReviewModel copyWith({
    String? ownerReply,
    String? replyDate,
    bool? isFlagged,
    bool? isPhotoReported,
    bool? isReviewReported,
    String? reportReason,
  }) {
    return ReviewModel(
      id: id,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      rating: rating,
      comment: comment,
      date: date,
      photos: photos,
      ownerReply: ownerReply ?? this.ownerReply,
      replyDate: replyDate ?? this.replyDate,
      isFlagged: isFlagged ?? this.isFlagged,
      isPhotoReported: isPhotoReported ?? this.isPhotoReported,
      isReviewReported: isReviewReported ?? this.isReviewReported,
      reportReason: reportReason ?? this.reportReason,
    );
  }
}

class PhotoModel {
  final String id;
  final String uploadedBy;
  final String restaurantId;
  final String restaurantName;
  final String imageUrl;
  final String date;
  bool isFlagged;

  PhotoModel({
    required this.id,
    required this.uploadedBy,
    required this.restaurantId,
    required this.restaurantName,
    required this.imageUrl,
    required this.date,
    this.isFlagged = false,
  });
}

class AppCredential {
  final String email;
  final String password;
  final String role;
  final String name;
  final String userId;

  AppCredential({
    required this.email,
    required this.password,
    required this.role,
    required this.name,
    required this.userId,
  });
}

class OwnerApplicationModel {
  final String id;
  final String userId;
  final String applicantName;
  final String businessName;
  final String category;
  final String address;
  final String phone;
  final String description;
  String status; // 'pending', 'approved', 'rejected'
  final String submittedDate;
  String? note;

  OwnerApplicationModel({
    required this.id,
    required this.userId,
    required this.applicantName,
    required this.businessName,
    required this.category,
    required this.address,
    required this.phone,
    required this.description,
    this.status = 'pending',
    required this.submittedDate,
    this.note,
  });
}

class ActivityLogModel {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final String type; // 'restaurant', 'user', 'review', 'photo', 'owner'

  ActivityLogModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
  });
}

// =================== DUMMY DATA ===================

class DummyData {
  // ─── Current User (untuk sisi user/pengguna) ─────────────────────────────
  static UserModel currentUser = UserModel(
    id: 'u1',
    name: 'Budi Santoso',
    email: 'budi@email.com',
    phone: '0812-1111-2222',
    joinDate: '2025-01-15',
    role: 'user',
  );

  // ─── Kredensial Login ────────────────────────────────────────────────────
  static List<AppCredential> credentials = [
    AppCredential(
      userId: 'u1',
      email: 'budi@email.com',
      password: 'user123',
      role: 'user',
      name: 'Budi Santoso',
    ),
    AppCredential(
      userId: 'o1',
      email: 'sari@warung.com',
      password: 'owner123',
      role: 'owner',
      name: 'Sari Lestari',
    ),
    AppCredential(
      userId: 'a1',
      email: 'admin@foodiespot.com',
      password: 'admin123',
      role: 'admin',
      name: 'Admin FoodieSpot',
    ),
  ];

  // ─── Daftar Pengguna (untuk panel admin) ─────────────────────────────────
  static List<UserModel> adminUsers = [
    UserModel(
      id: 'u2',
      name: 'Rina Kusuma',
      email: 'rina@email.com',
      phone: '0811-2222-3333',
      joinDate: '2024-01-10',
      role: 'user',
      status: 'aktif',
    ),
    UserModel(
      id: 'u3',
      name: 'Ahmad Fauzi',
      email: 'ahmad@email.com',
      phone: '0822-3333-4444',
      joinDate: '2024-02-05',
      role: 'user',
      status: 'aktif',
    ),
    UserModel(
      id: 'u4',
      name: 'Siti Nurhaliza',
      email: 'siti@email.com',
      phone: '0833-4444-5555',
      joinDate: '2024-03-12',
      role: 'user',
      status: 'aktif',
    ),
    UserModel(
      id: 'u9',
      name: 'Budi Setiawan',
      email: 'budi.s@email.com',
      phone: '0844-5555-6666',
      joinDate: '2024-04-20',
      role: 'user',
      status: 'banned',
    ),
    UserModel(
      id: 'u10',
      name: 'Lestari Dewi',
      email: 'lestari@email.com',
      phone: '0855-6666-7777',
      joinDate: '2024-05-08',
      role: 'user',
      status: 'aktif',
    ),
  ];

  // ─── Restoran ────────────────────────────────────────────────────────────
  // Dipakai bersama: user (browse), owner (kelola), admin (manajemen)
  static List<RestaurantModel> restaurants = [
    RestaurantModel(
      id: 'r1',
      name: 'Warung Nasi Gudeg Bu Sari',
      category: 'Masakan Jawa',
      rating: 4.8,
      reviewCount: 234,
      address: 'Jl. Malioboro No. 45, Yogyakarta',
      phone: '0274-123456',
      openHours: '07:00 - 21:00',
      distance: '150 m',
      priceRange: 'Rp 15.000 - 35.000',
      imageUrl:
          'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400',
      description:
          'Warung gudeg otentik dengan resep turun-temurun. Gudeg kami menggunakan gori muda pilihan dengan kuah santan yang kaya rempah.',
      isOpen: true,
      isFavorited: true,
      monthlyVisitors: 156,
      favoriteCount: 34,
    ),
    RestaurantModel(
      id: 'r2',
      name: 'Warung Pecel Lele',
      category: 'Masakan Rumahan',
      rating: 4.3,
      reviewCount: 120,
      address: 'Jl. Diponegoro No. 12, Yogyakarta',
      phone: '0274-654321',
      openHours: '10:00 - 22:00',
      distance: '1.2 km',
      priceRange: 'Rp 12.000',
      imageUrl:
          'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
      description:
          'Pecel lele segar dengan sambal terasi khas. Harga terjangkau, porsi besar.',
      isOpen: true,
      isFavorited: false,
      monthlyVisitors: 89,
      favoriteCount: 15,
    ),
    RestaurantModel(
      id: 'r3',
      name: 'Pizza & Pasta Bella',
      category: 'Western Food',
      rating: 4.1,
      reviewCount: 89,
      address: 'Jl. Gejayan No. 8, Yogyakarta',
      phone: '0274-789123',
      openHours: '11:00 - 23:00',
      distance: '1.8 km',
      priceRange: 'Rp 45.000',
      imageUrl:
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
      description:
          'Restaurant Italia modern dengan menu pizza autentik dan pasta segar.',
      isOpen: false,
      isFavorited: true,
      monthlyVisitors: 62,
      favoriteCount: 28,
    ),
    RestaurantModel(
      id: 'r4',
      name: 'Sate Madura Pak Karno',
      category: 'Sate & Grill',
      rating: 4.6,
      reviewCount: 310,
      address: 'Jl. Kaliurang Km 5, Yogyakarta',
      phone: '0274-456789',
      openHours: '16:00 - 00:00',
      distance: '320 m',
      priceRange: 'Rp 20.000',
      imageUrl:
          'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400',
      description:
          'Sate ayam dan kambing pilihan dengan bumbu kacang khas Madura.',
      isOpen: true,
      isFavorited: false,
      monthlyVisitors: 210,
      favoriteCount: 47,
    ),
    RestaurantModel(
      id: 'r5',
      name: 'Cafe Coklat Roema',
      category: 'Cafe & Kopi',
      rating: 4.4,
      reviewCount: 175,
      address: 'Jl. Prawirotaman No. 20, Yogyakarta',
      phone: '0274-321654',
      openHours: '08:00 - 22:00',
      distance: '500 m',
      priceRange: 'Rp 25.000 - 60.000',
      imageUrl:
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
      description:
          'Cafe cozy dengan menu kopi spesialti dan dessert coklat premium.',
      isOpen: true,
      isFavorited: false,
      monthlyVisitors: 134,
      favoriteCount: 39,
    ),
  ];

  // ─── Restoran milik owner (subset dari restaurants, bisa lebih dari 1) ──
  // Gunakan getter ini di OwnerHomeScreen sebagai daftar awal
  static List<RestaurantModel> get ownerRestaurants => [
        restaurants.firstWhere((r) => r.id == 'r1'),
        restaurants.firstWhere((r) => r.id == 'r2'),
      ];

  // ─── Review ──────────────────────────────────────────────────────────────
  // Gabungan: semua review dari berbagai user & restoran
  // Field baru (isPhotoReported, isReviewReported, reportReason) kompatibel
  // dengan owner screen; field lama (isFlagged) kompatibel dengan admin screen
  static List<ReviewModel> reviews = [
    ReviewModel(
      id: 'rv1',
      userId: 'u2',
      userName: 'Rina Kusuma',
      restaurantId: 'r4',
      restaurantName: 'Sate Madura Pak Karno',
      rating: 5.0,
      comment:
          'Sate-nya enak banget! Bumbu kacangnya kental dan gurih. Pelayanan ramah, harga terjangkau. Recommended!',
      date: '2024-06-12',
      isFlagged: false,
      isPhotoReported: false,
      isReviewReported: false,
    ),
    ReviewModel(
      id: 'rv2',
      userId: 'u9',
      userName: 'Budi Setiawan',
      restaurantId: 'r3',
      restaurantName: 'Pizza & Pasta Bella',
      rating: 1.0,
      comment:
          'PENIPUAN!!! Pesan jam 12 tapi datang jam 3!! Driver bilang terjebak macet tapi tracking ga jalan!!',
      date: '2024-06-11',
      isFlagged: true,
      isReviewReported: true,
      reportReason: 'Informasi palsu / tidak akurat',
    ),
    ReviewModel(
      id: 'rv3',
      userId: 'u4',
      userName: 'Siti Nurhaliza',
      restaurantId: 'r5',
      restaurantName: 'Cafe Coklat Roema',
      rating: 3.5,
      comment:
          'Kopinya enak, tempatnya nyaman. Agak mahal tapi worth it untuk nongkrong.',
      date: '2024-06-11',
      isFlagged: false,
      isPhotoReported: false,
      isReviewReported: false,
    ),
    ReviewModel(
      id: 'rv4',
      userId: 'u3',
      userName: 'Ahmad Fauzi',
      restaurantId: 'r2',
      restaurantName: 'Warung Pecel Lele',
      rating: 2.0,
      comment:
          'Tempat jorok, meja berminyak. Bakal kasih tahu semua orang buat ga makan di sini!!!',
      date: '2024-06-10',
      isFlagged: true,
      isReviewReported: true,
      reportReason: 'Mengandung kata kasar / ujaran kebencian',
    ),
    ReviewModel(
      id: 'rv5',
      userId: 'u10',
      userName: 'Lestari Dewi',
      restaurantId: 'r1',
      restaurantName: 'Warung Nasi Gudeg Bu Sari',
      rating: 5.0,
      comment:
          'Gudegnya enak banget! Kuahnya kental dan gurih, ayam opor empuk. Recommended banget untuk yang mau cari gudeg otentik Jogja.',
      date: '2024-06-09',
      photos: [
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'
      ],
      isFlagged: false,
      isPhotoReported: false,
      isReviewReported: false,
    ),
    ReviewModel(
      id: 'rv6',
      userId: 'u2',
      userName: 'Rina Kusuma',
      restaurantId: 'r1',
      restaurantName: 'Warung Nasi Gudeg Bu Sari',
      rating: 4.5,
      comment:
          'Tempatnya nyaman, pelayanan ramah. Gudeg sayur dan kreceknya bikin nagih. Harga juga wajar untuk porsi segitu.',
      date: '2024-06-08',
      ownerReply:
          'Terima kasih atas ulasannya kak Rina! Senang sekali bisa melayani. Kami akan terus berusaha memberikan yang terbaik 🙏',
      replyDate: '2024-06-09',
      isFlagged: false,
      isPhotoReported: false,
      isReviewReported: false,
    ),
    ReviewModel(
      id: 'rv7',
      userId: 'u3',
      userName: 'Ahmad Fauzi',
      restaurantId: 'r2',
      restaurantName: 'Warung Pecel Lele',
      rating: 4.0,
      comment:
          'Enak, tapi antrenya lumayan panjang. Worth it sih untuk rasanya.',
      date: '2024-06-07',
      isFlagged: false,
      isPhotoReported: false,
      isReviewReported: false,
    ),
  ];

  // ─── Foto ────────────────────────────────────────────────────────────────
  static List<PhotoModel> photos = [
    PhotoModel(
      id: 'ph1',
      uploadedBy: 'Rina Kusuma',
      restaurantId: 'r4',
      restaurantName: 'Sate Madura Pak Karno',
      imageUrl:
          'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400',
      date: '2024-06-12',
      isFlagged: false,
    ),
    PhotoModel(
      id: 'ph2',
      uploadedBy: 'Siti Nurhaliza',
      restaurantId: 'r5',
      restaurantName: 'Cafe Coklat Roema',
      imageUrl:
          'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400',
      date: '2024-06-11',
      isFlagged: false,
    ),
    PhotoModel(
      id: 'ph3',
      uploadedBy: 'Kevin Pratama',
      restaurantId: 'r3',
      restaurantName: 'Pizza & Pasta Bella',
      imageUrl:
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
      date: '2024-06-11',
      isFlagged: true,
    ),
    PhotoModel(
      id: 'ph4',
      uploadedBy: 'Ahmad Fauzi',
      restaurantId: 'r2',
      restaurantName: 'Warung Pecel Lele',
      imageUrl:
          'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
      date: '2024-06-10',
      isFlagged: false,
    ),
    PhotoModel(
      id: 'ph5',
      uploadedBy: 'Lestari Dewi',
      restaurantId: 'r1',
      restaurantName: 'Warung Nasi Gudeg Bu Sari',
      imageUrl:
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
      date: '2024-06-09',
      isFlagged: false,
    ),
  ];

  // ─── Pengajuan Owner ──────────────────────────────────────────────────────
  static List<OwnerApplicationModel> ownerApplications = [
    OwnerApplicationModel(
      id: 'app1',
      userId: 'u5',
      applicantName: 'Teguh Prabowo',
      businessName: 'Ayam Bakar Nusantara',
      category: 'Masakan Rumahan',
      address: 'Grogol, Jakarta Barat',
      phone: '0812-9988-7766',
      description:
          'Ayam bakar dengan bumbu rempah khas Nusantara, disajikan dengan lalapan dan sambal.',
      status: 'pending',
      submittedDate: '2024-06-10',
    ),
    OwnerApplicationModel(
      id: 'app2',
      userId: 'u6',
      applicantName: 'Maya Indah',
      businessName: 'Kafe Bunga Rampai',
      category: 'Cafe & Kopi',
      address: 'Cipete, Jakarta Selatan',
      phone: '0813-1122-3344',
      description:
          'Kafe dengan konsep taman bunga, menyajikan kopi manual brew dan menu dessert buatan sendiri.',
      status: 'pending',
      submittedDate: '2024-06-09',
    ),
    OwnerApplicationModel(
      id: 'app3',
      userId: 'u7',
      applicantName: 'Rizki Hamdani',
      businessName: 'Warung Pecel Lele Bu Yati',
      category: 'Masakan Rumahan',
      address: 'Tanah Abang, Jakarta Pusat',
      phone: '0821-5566-7788',
      description:
          'Pecel lele dan ayam goreng dengan sambal bawang pedas yang legendaris sejak 1998.',
      status: 'pending',
      submittedDate: '2024-06-08',
    ),
    OwnerApplicationModel(
      id: 'app4',
      userId: 'u8',
      applicantName: 'Fajar Nugroho',
      businessName: 'Pizza Ceria Express',
      category: 'Western Food',
      address: 'Kelapa Gading, Jakarta Utara',
      phone: '0878-3344-5566',
      description:
          'Pizza dengan topping melimpah dan harga terjangkau, cocok untuk keluarga.',
      status: 'approved',
      submittedDate: '2024-06-07',
    ),
  ];

  // ─── Log Aktivitas (untuk dashboard admin) ───────────────────────────────
  static List<ActivityLogModel> activityLogs = [
    ActivityLogModel(
      id: 'log1',
      title: 'Restoran baru terdaftar',
      subtitle: 'Warung Sate Madura Pak Hasan',
      time: '2 menit lalu',
      type: 'restaurant',
    ),
    ActivityLogModel(
      id: 'log2',
      title: 'Pengajuan owner masuk',
      subtitle: 'Maya Indah — Kafe Bunga Rampai',
      time: '15 menit lalu',
      type: 'owner',
    ),
    ActivityLogModel(
      id: 'log3',
      title: 'Review dilaporkan',
      subtitle: 'Ulasan Budi Setiawan di Pizza & Pasta Bella',
      time: '1 jam lalu',
      type: 'review',
    ),
    ActivityLogModel(
      id: 'log4',
      title: 'Pengguna baru terdaftar',
      subtitle: 'Farida Hanum (farida@email.com)',
      time: '2 jam lalu',
      type: 'user',
    ),
    ActivityLogModel(
      id: 'log5',
      title: 'Foto dilaporkan',
      subtitle: 'Foto oleh Kevin Pratama di Pizza & Pasta Bella',
      time: '3 jam lalu',
      type: 'photo',
    ),
    ActivityLogModel(
      id: 'log6',
      title: 'Pengajuan owner disetujui',
      subtitle: 'Fajar Nugroho — Pizza Ceria Express',
      time: '5 jam lalu',
      type: 'owner',
    ),
  ];

  // ─── Helper Methods ───────────────────────────────────────────────────────

  /// Review milik owner tertentu berdasarkan restoran yang dimiliki
  static List<ReviewModel> reviewsForOwner(List<String> restaurantIds) {
    return reviews
        .where((r) => restaurantIds.contains(r.restaurantId))
        .toList();
  }

  /// Pengajuan owner terbaru untuk user tertentu
  static OwnerApplicationModel? getActiveApplicationFor(String userId) {
    final apps =
        ownerApplications.where((a) => a.userId == userId).toList();
    if (apps.isEmpty) return null;
    apps.sort((a, b) => b.submittedDate.compareTo(a.submittedDate));
    return apps.first;
  }

  /// Review yang dilaporkan (untuk admin)
  static List<ReviewModel> get flaggedReviews =>
      reviews.where((r) => r.isFlagged).toList();

  /// Foto yang dilaporkan (untuk admin)
  static List<PhotoModel> get flaggedPhotos =>
      photos.where((p) => p.isFlagged).toList();

  /// Pengajuan owner yang masih pending (untuk admin)
  static List<OwnerApplicationModel> get pendingApplications =>
      ownerApplications.where((a) => a.status == 'pending').toList();
}
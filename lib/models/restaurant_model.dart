class RestaurantModel {
  final String id;
  String name;
  String address;
  String phone;
  String openHours;
  String priceRange;
  String description;
  String imageUrl;
  bool isOpen;
  double rating;
  int reviewCount;
  int monthlyVisitors;
  int favoriteCount;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.openHours,
    required this.priceRange,
    required this.description,
    required this.imageUrl,
    this.isOpen = true,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.monthlyVisitors = 0,
    this.favoriteCount = 0,
  });

  RestaurantModel copyWith({
    String? name,
    String? address,
    String? phone,
    String? openHours,
    String? priceRange,
    String? description,
    String? imageUrl,
    bool? isOpen,
    double? rating,
    int? reviewCount,
    int? monthlyVisitors,
    int? favoriteCount,
  }) {
    return RestaurantModel(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      openHours: openHours ?? this.openHours,
      priceRange: priceRange ?? this.priceRange,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isOpen: isOpen ?? this.isOpen,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      monthlyVisitors: monthlyVisitors ?? this.monthlyVisitors,
      favoriteCount: favoriteCount ?? this.favoriteCount,
    );
  }
}



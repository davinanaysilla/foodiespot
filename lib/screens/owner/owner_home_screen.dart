import 'package:flutter/material.dart';
import '../../models/tempat_makan_model.dart';
import '../../models/review_model.dart';
import '../../services/auth_service.dart';
import '../../services/owner_service.dart';
import '../../services/tempat_makan_service.dart';
import '../../services/review_service.dart';
import '../auth/login_screen.dart';
import 'owner_restaurant_list_screen.dart';
import 'owner_review_screen.dart';

const kBrown = Color(0xFF4A2512);
const kBrownLight = Color(0xFF6B3A1F);
const kCream = Color(0xFFF5F0E8);
const kAccent = Color(0xFFB5651D);

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({Key? key}) : super(key: key);

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  int _currentIndex = 0;
  List<TempatMakanModel> _restaurants = [];
  List<ReviewModel> _reviews = [];
  double _avgRating = 0.0;
  int _totalReviews = 0;
  int _totalPhotos = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Ambil list tempat makan milik owner
      final tmService = TempatMakanService();
      final myTM = await tmService.getMyTempatMakan();

      // 2. Ambil data dashboard owner
      final dashboardData = await OwnerService().getDashboard();
      final summary = dashboardData['summary'] as Map<String, dynamic>? ?? {};

      // 3. Ambil semua review untuk tempat makan milik owner
      List<ReviewModel> allReviews = [];
      final reviewService = ReviewService();
      for (var tm in myTM) {
        try {
          final revs = await reviewService.getReviews(tm.id);
          allReviews.addAll(revs);
        } catch (e) {
          debugPrint("Gagal mengambil review untuk ${tm.name}: $e");
        }
      }

      // Sort review terbaru di atas
      allReviews.sort((a, b) => b.id.compareTo(a.id));

      double parseDouble(dynamic val) {
        if (val == null) return 0.0;
        if (val is num) return val.toDouble();
        if (val is String) return double.tryParse(val) ?? 0.0;
        return 0.0;
      }

      int parseInt(dynamic val) {
        if (val == null) return 0;
        if (val is num) return val.toInt();
        if (val is String) return int.tryParse(val) ?? 0;
        return 0;
      }

      setState(() {
        _restaurants = myTM;
        _reviews = allReviews;
        _avgRating = parseDouble(summary['rata_rata_rating']);
        _totalReviews = parseInt(summary['total_review']);
        _totalPhotos = parseInt(summary['total_foto']);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _onRestaurantsUpdated() {
    _loadData();
  }

  void _onReviewsUpdated() {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: kCream,
        body: Center(
          child: CircularProgressIndicator(color: kBrown),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: kCream,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat data:\n$_errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: kBrown, fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBrown,
                    foregroundColor: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    final screens = [
      _DashboardTab(
        restaurants: _restaurants,
        reviews: _reviews,
        avgRating: _avgRating,
        totalReviews: _totalReviews,
        totalPhotos: _totalPhotos,
        onRefresh: _loadData,
      ),
      OwnerRestaurantListScreen(
        restaurants: _restaurants,
        onUpdated: _onRestaurantsUpdated,
      ),
      OwnerReviewScreen(
        restaurants: _restaurants,
        reviews: _reviews,
        onUpdated: _onReviewsUpdated,
      ),
    ];

    return Scaffold(
      backgroundColor: kCream,
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: kBrown,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Warung',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review_outlined),
            activeIcon: Icon(Icons.rate_review),
            label: 'Review',
          ),
        ],
      ),
    );
  }
}

// ─── Dashboard Tab ────────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  final List<TempatMakanModel> restaurants;
  final List<ReviewModel> reviews;
  final double avgRating;
  final int totalReviews;
  final int totalPhotos;
  final RefreshCallback onRefresh;

  const _DashboardTab({
    required this.restaurants,
    required this.reviews,
    required this.avgRating,
    required this.totalReviews,
    required this.totalPhotos,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: RefreshIndicator(
        onRefresh: onRefresh,
        color: kBrown,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kBrown, kBrownLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dashboard Pemilik',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Kelola bisnis kuliner Anda',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await AuthService().signOut();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      tooltip: 'Keluar',
                    ),
                  ],
                ),
              ),
            ),

            // Body
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Statistik gabungan
                  const Text(
                    'Statistik Semua Warung',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kBrown,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _StatCard(
                        icon: Icons.star_rounded,
                        iconColor: Colors.amber,
                        value: avgRating.toStringAsFixed(1),
                        label: 'Avg Rating',
                      ),
                      _StatCard(
                        icon: Icons.chat_bubble_outline_rounded,
                        iconColor: kBrown,
                        value: '$totalReviews',
                        label: 'Total Ulasan',
                      ),
                      _StatCard(
                        icon: Icons.photo_library_outlined,
                        iconColor: Colors.blue,
                        value: '$totalPhotos',
                        label: 'Total Foto',
                      ),
                      _StatCard(
                        icon: Icons.storefront_rounded,
                        iconColor: Colors.green,
                        value: '${restaurants.length}',
                        label: 'Jumlah Warung',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Ringkasan per warung
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Warung Saya',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kBrown,
                        ),
                      ),
                      Text(
                        '${restaurants.length} warung',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (restaurants.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Belum ada warung terdaftar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...restaurants.map(
                      (r) => _RestaurantSummaryCard(
                        restaurant: r,
                        reviewCount: reviews
                            .where((rv) => rv.tempatMakanId == r.id)
                            .length,
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Ulasan terbaru
                  const Text(
                    'Ulasan Terbaru',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kBrown,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (reviews.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Belum ada ulasan',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...reviews.take(3).map(
                          (r) => _MiniReviewCard(
                            review: r,
                            restaurantName: restaurants
                                .firstWhere(
                                  (res) => res.id == r.tempatMakanId,
                                  orElse: () => TempatMakanModel(
                                    id: 0,
                                    userId: 0,
                                    name: 'Warung',
                                    description: '',
                                    address: '',
                                    rating: 0.0,
                                  ),
                                )
                                .name,
                          ),
                        ),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kBrown,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ─── Restaurant Summary Card ──────────────────────────────────────────────────

class _RestaurantSummaryCard extends StatelessWidget {
  final TempatMakanModel restaurant;
  final int reviewCount;

  const _RestaurantSummaryCard({
    required this.restaurant,
    required this.reviewCount,
  });

  String _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://10.0.2.2:8000/storage/$url';
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = _resolveImageUrl(restaurant.imageUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: resolvedUrl.isNotEmpty
                ? Image.network(
                    resolvedUrl,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 54,
                      height: 54,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.storefront,
                          color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 54,
                    height: 54,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.storefront,
                        color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star,
                        color: Colors.amber, size: 14),
                    Text(
                      ' ${restaurant.rating.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.chat_bubble_outline,
                        size: 13, color: Colors.grey),
                    Text(
                      ' $reviewCount ulasan',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mini Review Card ─────────────────────────────────────────────────────────

class _MiniReviewCard extends StatelessWidget {
  final ReviewModel review;
  final String restaurantName;

  const _MiniReviewCard({
    required this.review,
    required this.restaurantName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge nama warung
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: kBrown.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              restaurantName,
              style: const TextStyle(
                fontSize: 11,
                color: kBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // User info & rating
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: kBrown,
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  review.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Komentar
          Text(
            review.comment,
            style: const TextStyle(fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
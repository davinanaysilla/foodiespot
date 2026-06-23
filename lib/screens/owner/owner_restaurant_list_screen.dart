import 'package:flutter/material.dart';
import '../../models/tempat_makan_model.dart';
import '../../utils/constants.dart';
import 'owner_restaurant_screen.dart';
import 'owner_add_restaurant_screen.dart';

const kBrown = Color(0xFF4A2512);
const kBrownLight = Color(0xFF6B3A1F);
const kCream = Color(0xFFF5F0E8);
const kAccent = Color(0xFFB5651D);

class OwnerRestaurantListScreen extends StatefulWidget {
  final List<TempatMakanModel> restaurants;
  final VoidCallback onUpdated;

  const OwnerRestaurantListScreen({
    Key? key,
    required this.restaurants,
    required this.onUpdated,
  }) : super(key: key);

  @override
  State<OwnerRestaurantListScreen> createState() =>
      _OwnerRestaurantListScreenState();
}

class _OwnerRestaurantListScreenState
    extends State<OwnerRestaurantListScreen> {
  late List<TempatMakanModel> _restaurants;

  @override
  void initState() {
    super.initState();
    _restaurants = List.from(widget.restaurants);
  }

  @override
  void didUpdateWidget(OwnerRestaurantListScreen old) {
    super.didUpdateWidget(old);
    _restaurants = List.from(widget.restaurants);
  }

  String _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://10.0.2.2:8000/storage/$url';
  }

  void _addRestaurant() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const OwnerAddRestaurantScreen()),
    );
    if (result == true) {
      widget.onUpdated();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Warung berhasil didaftarkan'),
          backgroundColor: kBrown,
        ),
      );
    }
  }

  void _openDetail(TempatMakanModel r) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerRestaurantScreen(
          restaurant: r,
          onUpdated: widget.onUpdated,
          onDeleted: widget.onUpdated,
        ),
      ),
    );

    if (result == true) {
      widget.onUpdated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: CustomScrollView(
        slivers: [
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
                        Text('Warung Saya',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Kelola semua warung Anda',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _addRestaurant,
                    icon: const Icon(Icons.add_circle_outline,
                        color: Colors.white, size: 28),
                    tooltip: 'Tambah Warung',
                  ),
                ],
              ),
            ),
          ),
          if (_restaurants.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.storefront_outlined,
                        size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Belum ada warung',
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrown,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _addRestaurant,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Daftarkan Warung',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _RestaurantCard(
                    restaurant: _restaurants[i],
                    imageUrl: _resolveImageUrl(_restaurants[i].imageUrl),
                    onTap: () => _openDetail(_restaurants[i]),
                  ),
                  childCount: _restaurants.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _restaurants.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: kBrown,
              onPressed: _addRestaurant,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Tambah Warung',
                  style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final TempatMakanModel restaurant;
  final String imageUrl;
  final VoidCallback onTap;
  const _RestaurantCard({
    required this.restaurant,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          height: 140,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image,
                              color: Colors.grey)),
                    )
                  : Container(
                      height: 140,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.storefront,
                          size: 48, color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: kAccent),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.address,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 15),
                      Text(' ${restaurant.rating.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/favorite_service.dart';
import '../../models/tempat_makan_model.dart';
import '../tempat_makan/detail_tempat_makan_page.dart';
import '../profile/notification_page.dart';
import '../../utils/constants.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late Future<List<TempatMakanModel>> _favoritesFuture;

  static const Color _bgColor = Color(0xFFFCF8F3);
  static const Color _textDark = Color(0xFF2C1A0E);
  static const Color _primaryBrown = Color(0xFF8B5E2A);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _favoritesFuture = FavoriteService().getFavorites();
    });
  }

  String _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return '${ApiConfig.baseUrl.replaceAll('/api', '')}/storage/$url';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text('Favorit', style: TextStyle(color: _textDark, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: _textDark),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage()));
            },
          )
        ],
      ),
      body: FutureBuilder<List<TempatMakanModel>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _primaryBrown));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Gagal memuat: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text("Belum ada warung favorit.", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final listWarung = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _fetchData(),
            color: _primaryBrown,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${listWarung.length} Tempat Tersimpan', style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFEAE0D5)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.tune_rounded, size: 14, color: _textDark),
                            SizedBox(width: 4),
                            Text('Urutkan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textDark)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: listWarung.length,
                    itemBuilder: (context, index) {
                      final item = listWarung[index];
                      final imageUrl = _resolveImageUrl(item.imageUrl);
                      
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DetailTempatMakanPage(tempatMakan: item)),
                          );
                          _fetchData(); // Refresh if unfavorited
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Image Section
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildPlaceholder())
                                        : _buildPlaceholder(),
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                      child: const Icon(Icons.favorite, color: _primaryBrown, size: 20),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                          const SizedBox(width: 4),
                                          Text(item.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textDark)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Info Section
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF9F5EF),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text('Indonesian Food', style: TextStyle(fontSize: 11, color: _textDark, fontWeight: FontWeight.w500)), // Mock tag
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.location_on, size: 12, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            item.address,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: const Color(0xFFEAE0D5),
      child: const Center(child: Icon(Icons.restaurant, size: 50, color: Colors.white)),
    );
  }
}


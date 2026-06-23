import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/tempat_makan_model.dart';
import '../../models/review_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/review_service.dart';
import '../../services/photo_service.dart';
import '../../services/favorite_service.dart';
import '../../utils/constants.dart';

class DetailTempatMakanPage extends StatefulWidget {
  final TempatMakanModel tempatMakan;
  const DetailTempatMakanPage({super.key, required this.tempatMakan});

  @override
  State<DetailTempatMakanPage> createState() => _DetailTempatMakanPageState();
}

class _DetailTempatMakanPageState extends State<DetailTempatMakanPage> {
  late Future<List<ReviewModel>> _reviewsFuture;
  UserModel? _currentUser;

  bool _isFavorite = false;
  bool _isLoadingFavorite = false;
  String _distanceStr = '';

  static const Color _bgColor = Color(0xFFFCF8F3);
  static const Color _primaryBrown = Color(0xFF8B5E2A);
  static const Color _textDark = Color(0xFF2C1A0E);
  static const Color _textGrey = Color(0xFF7A6A5E);
  static const Color _borderColor = Color(0xFFEAE0D5);
  static const Color _cardColor = Color(0xFFFDFBFA);

  @override
  void initState() {
    super.initState();
    _fetchData();
    _checkCurrentUser();
    _checkFavoriteStatus();
    _calculateDistance();
  }

  void _fetchData() {
    setState(() {
      _reviewsFuture = ReviewService().getReviews(widget.tempatMakan.id);
    });
  }

  void _checkCurrentUser() async {
    final user = await AuthService().getCurrentUser();
    if (mounted) setState(() => _currentUser = user);
  }

  void _checkFavoriteStatus() async {
    final status = await FavoriteService().checkFavorite(widget.tempatMakan.id);
    if (mounted) setState(() => _isFavorite = status);
  }

  Future<void> _calculateDistance() async {
    try {
      if (widget.tempatMakan.latitude == null ||
          widget.tempatMakan.longitude == null)
        return;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever)
        return;

      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null && mounted) {
        final dist = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          widget.tempatMakan.latitude!,
          widget.tempatMakan.longitude!,
        );
        setState(() {
          _distanceStr = dist < 1000
              ? '${dist.toStringAsFixed(0)} m'
              : '${(dist / 1000).toStringAsFixed(1)} km';
        });
      }
    } catch (_) {}
  }

  void _toggleFavorite() async {
    if (_isLoadingFavorite) return;
    setState(() => _isLoadingFavorite = true);
    try {
      final newStatus = await FavoriteService().toggleFavorite(
        widget.tempatMakan.id,
      );
      if (mounted) {
        setState(() => _isFavorite = newStatus);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus
                  ? "Ditambahkan ke Favorit ❤️"
                  : "Dihapus dari Favorit 💔",
            ),
            backgroundColor: newStatus ? Colors.pink : Colors.grey,
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => _isLoadingFavorite = false);
    }
  }

  String _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return '${ApiConfig.baseUrl.replaceAll('/api', '')}/storage/$url';
  }

  Future<void> _openNavigation() async {
    if (widget.tempatMakan.latitude == null ||
        widget.tempatMakan.longitude == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Koordinat tidak tersedia')));
      return;
    }
    final lat = widget.tempatMakan.latitude!;
    final lng = widget.tempatMakan.longitude!;
    final name = Uri.encodeComponent(widget.tempatMakan.name);

    final gmapsUri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    final webUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_name=$name',
    );

    if (await canLaunchUrl(gmapsUri)) {
      await launchUrl(gmapsUri);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  final List<String> _mockCategories = [
    'Makanan Tradisional',
    'Keluarga',
    'Halal',
  ];
  final List<String> _mockFacilities = [
    'Parkir Luas',
    'Ruang AC',
    'Toilet Bersih',
  ];
  final String _mockPrice = 'Rp 30k - 50k';
  final String _mockOpenHours = 'Setiap Hari\n07:00 - 21:00';
  final bool _mockIsOpen = true;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl(widget.tempatMakan.imageUrl);
    final isOwner = _currentUser?.id == widget.tempatMakan.userId;

    return Scaffold(
      backgroundColor: _bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320.0,
            pinned: true,
            backgroundColor: _bgColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: _textDark,
                    size: 20,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.share, color: _textDark, size: 20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 8.0,
                ).copyWith(right: 16),
                child: InkWell(
                  onTap: _toggleFavorite,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: _isLoadingFavorite
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.pink,
                            ),
                          )
                        : Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isFavorite ? Colors.pink : _textDark,
                            size: 20,
                          ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderImg(),
                    )
                  : _buildPlaceholderImg(),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: Container(
                height: 30,
                decoration: const BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              color: _bgColor,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tempatMakan.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _buildMetaChip(
                        icon: Icons.star_rounded,
                        iconColor: Colors.amber,
                        text: widget.tempatMakan.rating.toStringAsFixed(1),
                        subtext: '(120 Ulasan)',
                      ),
                      const SizedBox(width: 8),
                      _buildMetaChip(
                        icon: Icons.location_on_outlined,
                        text: _distanceStr.isNotEmpty ? _distanceStr : '1.2 km',
                      ),
                      const SizedBox(width: 8),
                      _buildMetaChip(
                        icon: Icons.payments_outlined,
                        text: _mockPrice,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openNavigation,
                          icon: const Icon(
                            Icons.directions_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text(
                            'Rute',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryBrown,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.phone_outlined,
                            color: _textDark,
                            size: 20,
                          ),
                          label: const Text(
                            'Telepon',
                            style: TextStyle(
                              color: _textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF7EFE5),
                            side: const BorderSide(color: _borderColor),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Tentang',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.tempatMakan.description.isNotEmpty
                        ? widget.tempatMakan.description
                        : 'Deskripsi tidak tersedia.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: _textGrey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _mockCategories
                        .map(
                          (c) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: _borderColor),
                              borderRadius: BorderRadius.circular(20),
                              color: _bgColor,
                            ),
                            child: Text(
                              c,
                              style: const TextStyle(
                                fontSize: 12,
                                color: _textGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 18,
                                    color: _primaryBrown,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Jam Buka',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _textDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _mockOpenHours,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _textGrey,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_mockIsOpen)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Buka Sekarang',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.restaurant,
                                    size: 18,
                                    color: _primaryBrown,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Fasilitas',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _textDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ..._mockFacilities.map(
                                (f) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: _textGrey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        f,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: _textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Lokasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.tempatMakan.address,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _textGrey,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _borderColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child:
                          widget.tempatMakan.latitude != null &&
                              widget.tempatMakan.longitude != null
                          ? FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(
                                  widget.tempatMakan.latitude!,
                                  widget.tempatMakan.longitude!,
                                ),
                                initialZoom: 15.0,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(
                                        widget.tempatMakan.latitude!,
                                        widget.tempatMakan.longitude!,
                                      ),
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              alignment: Alignment.center,
                              child: const Text(
                                'Peta tidak tersedia',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ulasan Teratas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showAddReviewModal,
                        child: const Text(
                          'Beri Ulasan',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _primaryBrown,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  FutureBuilder<List<ReviewModel>>(
                    future: _reviewsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: _primaryBrown,
                            ),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _borderColor),
                          ),
                          child: const Text(
                            "Belum ada ulasan.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _textGrey),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: snapshot.data!.length > 5
                            ? 5
                            : snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final review = snapshot.data![index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: _borderColor,
                                      backgroundImage:
                                          review.userPhotoUrl != null
                                          ? NetworkImage(
                                              _resolveImageUrl(
                                                review.userPhotoUrl!,
                                              ),
                                            )
                                          : null,
                                      child: review.userPhotoUrl == null
                                          ? Text(
                                              review.userName.isNotEmpty
                                                  ? review.userName[0]
                                                        .toUpperCase()
                                                  : 'U',
                                              style: const TextStyle(
                                                color: _textDark,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            review.userName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: _textDark,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const Text(
                                            'Baru saja',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (starIndex) => Icon(
                                          starIndex < review.rating
                                              ? Icons.star_rounded
                                              : Icons.star_border_rounded,
                                          size: 16,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (review.comment.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    review.comment,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: _textGrey,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                                if (review.imageUrl != null &&
                                    review.imageUrl!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      _resolveImageUrl(review.imageUrl!),
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                                if (review.reply != null &&
                                    review.reply!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9F9F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Balasan Pemilik",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: _primaryBrown,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          review.reply!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: _textGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                if (isOwner) ...[
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => _showReplyModal(review),
                                      child: Text(
                                        review.reply == null
                                            ? 'Balas'
                                            : 'Edit Balasan',
                                        style: const TextStyle(
                                          color: _primaryBrown,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    Color iconColor = _textDark,
    required String text,
    String? subtext,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EAE0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
          if (subtext != null) ...[
            const SizedBox(width: 4),
            Text(
              subtext,
              style: const TextStyle(fontSize: 11, color: _textGrey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholderImg() {
    return Container(
      color: _borderColor,
      child: const Center(
        child: Icon(Icons.restaurant, size: 60, color: Colors.white),
      ),
    );
  }

  void _showAddReviewModal() {
    int selectedRating = 5;
    final commentCtrl = TextEditingController();
    File? selectedImage;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Tulis Ulasan",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    icon: Icon(
                      index < selectedRating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 48,
                    ),
                    onPressed: () =>
                        setModalState(() => selectedRating = index + 1),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Bagaimana pengalaman Anda?",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _primaryBrown),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 50,
                  );
                  if (pickedFile != null)
                    setModalState(() => selectedImage = File(pickedFile.path));
                },
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: _bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _borderColor,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            selectedImage!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              color: _textGrey,
                              size: 28,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Tambahkan Foto (Opsional)",
                              style: TextStyle(color: _textGrey, fontSize: 13),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        setModalState(() => isSubmitting = true);
                        try {
                          await ReviewService().addReview(
                            widget.tempatMakan.id,
                            selectedRating,
                            commentCtrl.text.trim(),
                            imageFile: selectedImage,
                          );
                          if (!ctx.mounted || !mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Ulasan terkirim!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _fetchData();
                        } catch (e) {
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                        } finally {
                          if (mounted)
                            setModalState(() => isSubmitting = false);
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Kirim Ulasan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showReplyModal(ReviewModel review) {
    final replyCtrl = TextEditingController(text: review.reply ?? '');
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Balas Ulasan",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '"${review.comment}"',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: _textGrey,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: replyCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Tulis balasan Anda...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _primaryBrown),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (replyCtrl.text.isEmpty) return;
                        setModalState(() => isSubmitting = true);
                        try {
                          await ReviewService().replyReview(
                            review.id,
                            replyCtrl.text.trim(),
                          );
                          if (!ctx.mounted || !mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Berhasil membalas!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _fetchData();
                        } catch (e) {
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                        } finally {
                          if (mounted)
                            setModalState(() => isSubmitting = false);
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Kirim Balasan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

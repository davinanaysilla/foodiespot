import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/dummy_data.dart';
import '../../widgets/common_widgets.dart';
import 'restaurant_detail_screen.dart';

class UserMapScreen extends StatefulWidget {
  const UserMapScreen({Key? key}) : super(key: key);

  @override
  State<UserMapScreen> createState() => _UserMapScreenState();
}

class _UserMapScreenState extends State<UserMapScreen> {
  bool _showList = false;
  String _sortBy = 'Terdekat';
  final List<String> _sortOptions = ['Terdekat', 'Rating', 'Ulasan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _showList ? _buildListView() : _buildMapView(),
    );
  }

  Widget _buildMapView() {
    final nearest = DummyData.restaurants.first;
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text('Peta Kuliner',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showList = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Daftar', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),

          // Map placeholder
          Expanded(
            flex: 3,
            child: Container(
              color: const Color(0xFFE8EFE4),
              child: Stack(
                children: [
                  // Grid lines simulating map
                  CustomPaint(
                    painter: _MapPainter(),
                    child: Container(),
                  ),
                  // Map pins
                  ..._buildMapPins(),
                  // Controls
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      children: [
                        _MapButton(icon: Icons.add, onTap: () {}),
                        const SizedBox(height: 8),
                        _MapButton(icon: Icons.remove, onTap: () {}),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Column(
                      children: [
                        _MapButton(icon: Icons.layers_outlined, onTap: () {}),
                        const SizedBox(height: 8),
                        _MapButton(icon: Icons.my_location, onTap: () {}),
                      ],
                    ),
                  ),
                  // Road label
                  Positioned(
                    top: 80,
                    left: 40,
                    child: Transform.rotate(
                      angle: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('Jl. Malioboro', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom sheet
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tempat terdekat', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RestaurantDetailScreen(restaurant: nearest))),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(nearest.imageUrl, width: 54, height: 54, fit: BoxFit.cover,
                            errorBuilder: (c, _, __) => Container(width: 54, height: 54, color: AppColors.cardBg)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nearest.name.length > 20 ? 'nearest.name.substring(0, 20) + ...' : nearest.name,
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 12, color: AppColors.star),
                                  Text(' ${nearest.rating}  ', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                                  const Icon(Icons.location_on, size: 12, color: AppColors.error),
                                  Text(nearest.distance, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.access_time, size: 12, color: AppColors.textLight),
                                  Text(' ${nearest.openHours.split(' ').first}', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textLight)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text('Detail →', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Semua Terdekat', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: DummyData.restaurants.length,
                    itemBuilder: (ctx, i) {
                      final r = DummyData.restaurants[i];
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RestaurantDetailScreen(restaurant: r))),
                        child: Container(
                          width: 90,
                          margin: const EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(r.imageUrl, width: 60, height: 55, fit: BoxFit.cover,
                                  errorBuilder: (c, _, __) => Container(width: 60, height: 55, color: AppColors.cardBg)),
                              ),
                              const SizedBox(height: 4),
                              Text(r.name.split(' ').take(2).join(' '),
                                style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textSecondary),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.location_on, size: 9, color: AppColors.error),
                                  Text(r.distance, style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textLight)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMapPins() {
    final positions = [
      const Offset(120, 80),
      const Offset(180, 130),
      const Offset(230, 90),
      const Offset(150, 200),
      const Offset(80, 170),
    ];
    return List.generate(DummyData.restaurants.length, (i) {
      final pos = positions[i % positions.length];
      return Positioned(
        left: pos.dx,
        top: pos.dy,
        child: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => RestaurantDetailScreen(restaurant: DummyData.restaurants[i]))),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: i == 0 ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, size: 12, color: AppColors.error),
                    const SizedBox(width: 3),
                    Text(
                      DummyData.restaurants[i].category.split(' ').first,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: i == 0 ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 2, height: 8, color: i == 0 ? AppColors.primary : Colors.white),
              Container(width: 6, height: 6, decoration: BoxDecoration(
                color: i == 0 ? AppColors.primary : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)],
              )),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildListView() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _showList = false),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Tempat Makan Terdekat',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ],
            ),
          ),
          // Search + filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  height: 44,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(Icons.search, color: AppColors.textLight, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari nama tempat...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.zero,
                            hintStyle: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: _sortOptions.map((opt) {
                    final selected = opt == _sortBy;
                    return GestureDetector(
                      onTap: () => setState(() => _sortBy = opt),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                        ),
                        child: Text(opt, style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? Colors.white : AppColors.textSecondary,
                        )),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: DummyData.restaurants.length,
              itemBuilder: (ctx, i) => RestaurantCard(
                restaurant: DummyData.restaurants[i],
                onTap: () => Navigator.push(ctx, MaterialPageRoute(
                  builder: (_) => RestaurantDetailScreen(restaurant: DummyData.restaurants[i]))),
                onFavorite: () => setState(() => DummyData.restaurants[i].isFavorited = !DummyData.restaurants[i].isFavorited),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 6)],
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCFD8DC).withValues(alpha: 0.5)
      ..strokeWidth = 1;

    // Horizontal lines
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Road
    final roadPaint = Paint()..color = const Color(0xFFFFFFFF)..strokeWidth = 8;
    canvas.drawLine(const Offset(0, 100), Offset(size.width, 100), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
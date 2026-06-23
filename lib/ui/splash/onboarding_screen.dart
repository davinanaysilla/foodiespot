import 'package:flutter/material.dart';
import '../auth/login_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Cari Restoran Terdekat',
      'subtitle':
          'Temukan tempat makan terbaik di sekitarmu dengan mudah dan cepat melalui peta interaktif kami.',
      'icon': Icons.location_city_rounded,
      'bgIcon': Icons.map_outlined,
    },
    {
      'title': 'Rating & Ulasan Terpercaya',
      'subtitle':
          'Baca ulasan nyata dari sesama foodie dan pilih tempat makan terbaik berdasarkan pengalaman mereka.',
      'icon': Icons.star_rounded,
      'bgIcon': Icons.rate_review_outlined,
    },
    {
      'title': 'Favorit & Simpan Tempat',
      'subtitle':
          'Simpan tempat makan favoritmu dan akses kapan saja untuk pengalaman kuliner terbaik.',
      'icon': Icons.favorite_rounded,
      'bgIcon': Icons.bookmark_outline,
    },
  ];

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Tombol Lewati di kanan atas
            Padding(
              padding: const EdgeInsets.only(top: 12, right: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: _currentPage < _pages.length - 1
                    ? TextButton(
                        onPressed: _goToLogin,
                        child: const Text(
                          'Lewati',
                          style: TextStyle(
                            color: Color(0xFF8B5E2A),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : const SizedBox(height: 40),
              ),
            ),

            // PageView konten
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Dots Indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFF8B5E2A)
                          : const Color(0xFFD4B483),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Tombol Lanjut
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5E2A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _goToLogin();
                    }
                  },
                  child: Text(
                    _currentPage < _pages.length - 1
                        ? 'Lanjut'
                        : 'Mulai Sekarang',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Ilustrasi bulat dengan ikon
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF5ECD7),
                  Color(0xFFE8D5A3),
                  Color(0xFFD4B483),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4B483).withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background icon besar (dekoratif)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Icon(
                    page['bgIcon'] as IconData,
                    size: 80,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
                // Bangunan kota / ilustrasi utama
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Simulasi gedung-gedung kota
                    _buildCityIllustration(page['icon'] as IconData),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // Judul
          Text(
            page['title'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C1A0E),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Deskripsi
          Text(
            page['subtitle'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityIllustration(IconData mainIcon) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Gedung-gedung kecil (latar)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBuilding(40, 70, const Color(0xFFC49A5A)),
            const SizedBox(width: 4),
            _buildBuilding(35, 90, const Color(0xFF8B5E2A)),
            const SizedBox(width: 4),
            _buildBuilding(45, 60, const Color(0xFFC49A5A)),
          ],
        ),
        // Icon utama di tengah
        Positioned(
          top: -10,
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(mainIcon, color: const Color(0xFF8B5E2A), size: 30),
          ),
        ),
      ],
    );
  }

  Widget _buildBuilding(double width, double height, Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Jendela-jendela kecil
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: List.generate(
              6,
              (_) => Container(
                width: 6,
                height: 6,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

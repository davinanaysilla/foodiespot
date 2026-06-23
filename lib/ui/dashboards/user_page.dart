import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/tempat_makan_service.dart';
import '../../services/pengajuan_owner.dart';
import '../../models/tempat_makan_model.dart';
import '../../models/user_model.dart';
import '../../models/pengajuan_owner_model.dart';
import '../profile/profile_page.dart';
import '../profile/notification_page.dart';
import '../tempat_makan/detail_tempat_makan_page.dart';
import '../dashboards/favorite_page.dart';
import '../dashboards/peta_page.dart';
import '../dashboards/search_result_page.dart';
import '../../utils/constants.dart';

// ============================================================
// USER HOME PAGE — DENGAN BOTTOM NAVIGATION
// ============================================================
class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _currentTab = 0;
  late List<TempatMakanModel> _allData;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _allData = [];
    _loadData();
  }

  void _loadData() async {
    try {
      final data = await TempatMakanService().getTempatMakan();
      if (mounted) setState(() { _allData = data; _dataLoaded = true; });
    } catch (_) {
      if (mounted) setState(() => _dataLoaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _BerandaPage(allData: _allData, dataLoaded: _dataLoaded, onRefresh: _loadData),
      PetaPage(tempatMakanList: _allData),
      const FavoritePage(),
      _UlasanPage(),
      _ProfilTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EE),
      body: IndexedStack(index: _currentTab, children: pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Beranda'},
      {'icon': Icons.map_rounded, 'label': 'Peta'},
      {'icon': Icons.favorite_rounded, 'label': 'Favorit'},
      {'icon': Icons.star_rounded, 'label': 'Ulasan'},
      {'icon': Icons.person_rounded, 'label': 'Profil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final active = _currentTab == i;
              return GestureDetector(
                onTap: () => setState(() => _currentTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF8B5E2A) : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        size: 22,
                        color: active ? Colors.white : Colors.grey[400],
                      ),
                      if (active) ...[
                        const SizedBox(width: 6),
                        Text(
                          items[i]['label'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BERANDA PAGE
// ============================================================
class _BerandaPage extends StatefulWidget {
  final List<TempatMakanModel> allData;
  final bool dataLoaded;
  final VoidCallback onRefresh;

  const _BerandaPage({
    required this.allData,
    required this.dataLoaded,
    required this.onRefresh,
  });

  @override
  State<_BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<_BerandaPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedTab = 'Semua';
  final List<String> _tabs = ['Semua', 'Indonesia', 'Western', 'Asian'];
  PengajuanOwnerModel? _pengajuan;
  bool _isLoadingPengajuan = true;

  @override
  void initState() {
    super.initState();
    _fetchStatusPengajuan();
  }

  void _fetchStatusPengajuan() async {
    setState(() => _isLoadingPengajuan = true);
    try {
      final data = await PengajuanOwnerService().cekStatus();
      if (mounted) setState(() => _pengajuan = data);
    } catch (_) {}
    finally {
      if (mounted) setState(() => _isLoadingPengajuan = false);
    }
  }

  String _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    String rootUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    return '$rootUrl/storage/$url';
  }

  void _goToSearch(String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HasilPencarianPage(
          initialQuery: query,
          allData: widget.allData,
        ),
      ),
    );
  }

  void _showMitraModal() {
    final namaTokoCtrl = TextEditingController();
    final deskripsiTokoCtrl = TextEditingController();
    final alamatCtrl = TextEditingController();
    File? selectedKtp;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 20, right: 20, top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_pengajuan == null) ...[
                      const Text(
                        'Formulir Kemitraan Owner',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C1A0E)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _modalField(controller: namaTokoCtrl, label: 'Nama Tempat Makan', icon: Icons.store_outlined),
                      const SizedBox(height: 12),
                      _modalField(controller: alamatCtrl, label: 'Alamat Lengkap', icon: Icons.location_on_outlined, maxLines: 2),
                      const SizedBox(height: 12),
                      _modalField(controller: deskripsiTokoCtrl, label: 'Deskripsi Singkat', icon: Icons.description_outlined, maxLines: 2),
                      const SizedBox(height: 16),
                      const Text('Upload Kartu Identitas (KTP)',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C1A0E))),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 30);
                          if (pickedFile != null) {
                            setModalState(() => selectedKtp = File(pickedFile.path));
                          }
                        },
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5ECD7),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFDDD0BC)),
                          ),
                          child: selectedKtp != null
                              ? ClipRRect(borderRadius: BorderRadius.circular(14),
                                  child: Image.file(selectedKtp!, width: double.infinity, fit: BoxFit.cover))
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.credit_card, color: Color(0xFF8B5E2A), size: 32),
                                    SizedBox(height: 8),
                                    Text('Pilih Foto KTP', style: TextStyle(color: Color(0xFF8B5E2A))),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      isSubmitting
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5E2A)))
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5E2A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () async {
                                if (namaTokoCtrl.text.isEmpty || deskripsiTokoCtrl.text.isEmpty || alamatCtrl.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Semua kolom teks wajib diisi!'), backgroundColor: Colors.red));
                                  return;
                                }
                                if (selectedKtp == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Foto KTP wajib diunggah!'), backgroundColor: Colors.red));
                                  return;
                                }
                                setModalState(() => isSubmitting = true);
                                try {
                                  await PengajuanOwnerService().ajukan(
                                    namaTokoCtrl.text.trim(),
                                    deskripsiTokoCtrl.text.trim(),
                                    alamatCtrl.text.trim(),
                                    selectedKtp!,
                                  );
                                  if (!ctx.mounted || !mounted) return;
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Pengajuan berhasil dikirim!'), backgroundColor: Color(0xFF38A169)));
                                  _fetchStatusPengajuan();
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
                                  setModalState(() => isSubmitting = false);
                                }
                              },
                              child: const Text('Kirim Pengajuan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                    ] else ...[
                      const Icon(Icons.access_time_filled, color: Color(0xFF8B5E2A), size: 60),
                      const SizedBox(height: 12),
                      const Text('Pengajuan Diproses',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B5E2A)),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text("Toko '${_pengajuan!.namaToko}' sedang direview oleh Admin. Mohon bersabar ya!",
                          textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Color(0xFF666666))),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: () async {
                          setModalState(() => isSubmitting = true);
                          try {
                            await PengajuanOwnerService().batalkan();
                            if (!ctx.mounted || !mounted) return;
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pengajuan dibatalkan'), backgroundColor: Colors.orange));
                            _fetchStatusPengajuan();
                          } catch (e) {
                            if (!mounted) return;
                            setModalState(() => isSubmitting = false);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Batalkan Pengajuan'),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _modalField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFC49A5A), size: 20),
        filled: true,
        fillColor: const Color(0xFFF9F5EF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDD0BC))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDD0BC))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF8B5E2A), width: 1.8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EE),
      body: RefreshIndicator(
        onRefresh: () async => widget.onRefresh(),
        color: const Color(0xFF8B5E2A),
        child: CustomScrollView(
          slivers: [
            // ── APP BAR ──
            SliverToBoxAdapter(child: _buildHeader()),

            // ── SEARCH BAR ──
            SliverToBoxAdapter(child: _buildSearchBar()),

            // ── CATEGORY TABS ──
            SliverToBoxAdapter(child: _buildCategoryTabs()),

            // ── RESTORAN TERDEKAT ──
            SliverToBoxAdapter(
              child: _buildSectionHeader('Restoran Terdekat', 'Lihat Semua', () => _goToSearch('')),
            ),
            SliverToBoxAdapter(child: _buildNearbyRestaurants()),

            // ── BANNER MITRA ──
            SliverToBoxAdapter(child: _buildMitraBanner()),

            // ── SEDANG TRENDING ──
            SliverToBoxAdapter(
              child: _buildSectionHeader('Sedang Trending', null, null),
            ),
            SliverToBoxAdapter(child: _buildTrendingList()),

            // ── REKOMENDASI ──
            SliverToBoxAdapter(
              child: _buildSectionHeader('Rekomendasi Untukmu', null, null),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  if (!widget.dataLoaded) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(color: Color(0xFF8B5E2A)),
                      ),
                    );
                  }
                  if (widget.allData.isEmpty) return const SizedBox();
                  final item = widget.allData[i % widget.allData.length];
                  return _buildRekomendasiCard(item);
                },
                childCount: widget.dataLoaded
                    ? (widget.allData.isEmpty ? 1 : widget.allData.length.clamp(0, 6))
                    : 1,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B4226), Color(0xFF8B5E2A), Color(0xFFC49A5A)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FoodieSpot',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: Colors.white70, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            'Jelajahi Kuliner Jakarta',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (!_isLoadingPengajuan)
                        GestureDetector(
                          onTap: _showMitraModal,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _pengajuan == null
                                      ? Icons.storefront_rounded
                                      : Icons.hourglass_top_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _pengajuan == null ? 'Jadi Mitra' : 'Pending',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      // Notifikasi Bell
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage()));
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Hero Banner
            Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF5A3515), Color(0xFF8B5E2A)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Pattern dekoratif
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 30,
                    bottom: -30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  // Icon restoran besar
                  Positioned(
                    right: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Icon(
                        Icons.restaurant_menu_rounded,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  // Teks
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Temukan Kuliner\nFavoritmu! 🍜',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Jelajahi Sekarang →',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B5E2A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: GestureDetector(
        onTap: () => _goToSearch(''),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF5ECD7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(Icons.search, color: Color(0xFFC49A5A), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onSubmitted: _goToSearch,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF2C1A0E)),
                  decoration: InputDecoration(
                    hintText: 'Cari makanan atau restoran...',
                    hintStyle:
                        TextStyle(color: Colors.grey[400], fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5E2A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: _tabs.map((tab) {
                final active = _selectedTab == tab;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTab = tab),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFF8B5E2A)
                          : const Color(0xFFF5ECD7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: active
                            ? Colors.white
                            : const Color(0xFF8B5E2A),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Divider(height: 1, color: Colors.grey[100]),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? linkText, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C1A0E),
            ),
          ),
          if (linkText != null)
            GestureDetector(
              onTap: onTap,
              child: Text(
                linkText,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8B5E2A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNearbyRestaurants() {
    if (!widget.dataLoaded) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF8B5E2A))),
      );
    }
    if (widget.allData.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Text('Belum ada restoran',
            style: TextStyle(color: Colors.grey[400], fontSize: 14)),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
        itemCount: widget.allData.length.clamp(0, 8),
        itemBuilder: (ctx, i) {
          final item = widget.allData[i];
          final imageUrl = _resolveImageUrl(item.imageUrl);
          return GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => DetailTempatMakanPage(tempatMakan: item))),
            child: Container(
              width: 155,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Stack(
                      children: [
                        imageUrl.isNotEmpty
                            ? Image.network(imageUrl,
                                height: 110, width: double.infinity, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _cardPlaceholder(110))
                            : _cardPlaceholder(110),
                        Positioned(
                          top: 8, right: 8,
                          child: Container(
                            width: 28, height: 28,
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.favorite_border_rounded,
                                color: Color(0xFF8B5E2A), size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Info
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C1A0E))),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFF5A623), size: 13),
                            const SizedBox(width: 3),
                            Text(item.rating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(' • 1.2 km',
                                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMitraBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A2512), Color(0xFF8B5E2A)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                          color: Color(0xFFF5A623), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('Punya Bisnis Kuliner?',
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Daftar jadi mitra FoodieSpot dan kembangkan bisnis kamu sekarang!',
                  style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _showMitraModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Daftar Sekarang',
                        style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8B5E2A))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.storefront_rounded, size: 60, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildTrendingList() {
    if (!widget.dataLoaded || widget.allData.isEmpty) return const SizedBox(height: 140);

    final trending = [...widget.allData]
      ..sort((a, b) => b.rating.compareTo(a.rating));

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
        itemCount: trending.length.clamp(0, 6),
        itemBuilder: (ctx, i) {
          final item = trending[i];
          final imageUrl = _resolveImageUrl(item.imageUrl);
          return GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => DetailTempatMakanPage(tempatMakan: item))),
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: imageUrl.isNotEmpty
                        ? Image.network(imageUrl,
                            width: 130, height: 130, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _cardPlaceholder(130))
                        : _cardPlaceholder(130),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                  // Label bawah
                  Positioned(
                    bottom: 8, left: 8, right: 8,
                    child: Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRekomendasiCard(TempatMakanModel item) {
    final imageUrl = _resolveImageUrl(item.imageUrl);
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => DetailTempatMakanPage(tempatMakan: item))),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Foto kiri
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl,
                      width: 90, height: 90, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _cardPlaceholder2())
                  : _cardPlaceholder2(),
            ),
            // Info kanan
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1A0E),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.description.isNotEmpty ? item.description : 'Restoran',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFF5A623), size: 14),
                        const SizedBox(width: 3),
                        Text(
                          item.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C1A0E),
                          ),
                        ),
                        Text(' • 1.5 km',
                            style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Harga kanan
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5ECD7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Rp 15rb',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B5E2A),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardPlaceholder(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFFE8D5A3),
      child: const Icon(Icons.restaurant_menu_rounded,
          color: Color(0xFF8B5E2A), size: 32),
    );
  }

  Widget _cardPlaceholder2() {
    return Container(
      width: 90, height: 90,
      color: const Color(0xFFE8D5A3),
      child: const Icon(Icons.restaurant_menu_rounded,
          color: Color(0xFF8B5E2A), size: 28),
    );
  }
}

// ============================================================
// ULASAN PAGE (placeholder tab)
// ============================================================
class _UlasanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EE),
      appBar: AppBar(
        title: const Text('Ulasan Saya'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C1A0E),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_outline_rounded, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Belum ada ulasan',
                style: TextStyle(
                    fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text('Ulasanmu akan muncul di sini',
                style: TextStyle(fontSize: 13, color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PROFIL TAB (Wrapper)
// ============================================================
class _ProfilTab extends StatefulWidget {
  @override
  State<_ProfilTab> createState() => _ProfilTabState();
}

class _ProfilTabState extends State<_ProfilTab> {
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final u = await AuthService().getCurrentUser();
    if (mounted) setState(() { _user = u; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF8B5E2A))),
      );
    }
    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('Tidak dapat memuat profil')),
      );
    }
    return ProfilePage(user: _user!);
  }
}

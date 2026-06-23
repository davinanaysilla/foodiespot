import 'package:flutter/material.dart';
import '../../models/tempat_makan_model.dart';
import '../../utils/constants.dart';
import '../tempat_makan/detail_tempat_makan_page.dart';

// ============================================================
// FILTER MODEL
// ============================================================
class FilterOptions {
  Set<String> kategori;
  double jarakMaksimal;
  int minRating;
  Set<String> rentangHarga;
  bool bukaSekarang;
  bool promoTersedia;

  FilterOptions({
    Set<String>? kategori,
    this.jarakMaksimal = 5.0,
    this.minRating = 0,
    Set<String>? rentangHarga,
    this.bukaSekarang = false,
    this.promoTersedia = false,
  })  : kategori = kategori ?? {},
        rentangHarga = rentangHarga ?? {};

  bool get isActive =>
      kategori.isNotEmpty ||
      jarakMaksimal < 10.0 ||
      minRating > 0 ||
      rentangHarga.isNotEmpty ||
      bukaSekarang ||
      promoTersedia;
}

// ============================================================
// FILTER PAGE (Modal Bottom Sheet)
// ============================================================
class FilterPage extends StatefulWidget {
  final FilterOptions initialFilter;
  const FilterPage({super.key, required this.initialFilter});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late FilterOptions _filter;

  final List<String> _kategoriList = [
    'Halal',
    'Cepat Saji',
    'Kafe',
    'Fine Dining',
    'Kaki Lima',
    'Vegetarian',
    'Bar & Lounge',
  ];

  @override
  void initState() {
    super.initState();
    // Clone filter agar tidak mutate langsung
    _filter = FilterOptions(
      kategori: Set.from(widget.initialFilter.kategori),
      jarakMaksimal: widget.initialFilter.jarakMaksimal,
      minRating: widget.initialFilter.minRating,
      rentangHarga: Set.from(widget.initialFilter.rentangHarga),
      bukaSekarang: widget.initialFilter.bukaSekarang,
      promoTersedia: widget.initialFilter.promoTersedia,
    );
  }

  void _reset() {
    setState(() {
      _filter = FilterOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5ECD7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.close, color: Color(0xFF8B5E2A), size: 18),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Filter',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1A0E),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _reset,
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      color: Color(0xFF8B5E2A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Divider
                  Divider(color: Colors.grey[200], height: 1),
                  const SizedBox(height: 20),

                  // --- KATEGORI ---
                  const _SectionTitle(text: 'Kategori'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _kategoriList.map((kat) {
                      final selected = _filter.kategori.contains(kat);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _filter.kategori.remove(kat);
                            } else {
                              _filter.kategori.add(kat);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF8B5E2A)
                                : const Color(0xFFF5ECD7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF8B5E2A)
                                  : const Color(0xFFDDD0BC),
                            ),
                          ),
                          child: Text(
                            kat,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF8B5E2A),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // --- JARAK MAKSIMAL ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _SectionTitle(text: 'Jarak Maksimal'),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5ECD7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_filter.jarakMaksimal.toStringAsFixed(0)} km',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8B5E2A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: const Color(0xFF8B5E2A),
                      inactiveTrackColor: const Color(0xFFE8D5A3),
                      thumbColor: const Color(0xFF8B5E2A),
                      overlayColor:
                          const Color(0xFF8B5E2A).withValues(alpha: 0.2),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _filter.jarakMaksimal,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      onChanged: (v) => setState(() => _filter.jarakMaksimal = v),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1 km',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12)),
                        Text('10 km',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- MINIMAL RATING ---
                  const _SectionTitle(text: 'Minimal Rating'),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(5, (i) {
                      final starVal = i + 1;
                      return GestureDetector(
                        onTap: () => setState(() => _filter.minRating =
                            _filter.minRating == starVal ? 0 : starVal),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            starVal <= _filter.minRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: starVal <= _filter.minRating
                                ? const Color(0xFFF5A623)
                                : Colors.grey[400],
                            size: 32,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // --- RENTANG HARGA ---
                  const _SectionTitle(text: 'Rentang Harga'),
                  const SizedBox(height: 12),
                  Row(
                    children: ['\$', '\$\$', '\$\$\$', '\$\$\$\$'].map((h) {
                      final selected = _filter.rentangHarga.contains(h);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _filter.rentangHarga.remove(h);
                            } else {
                              _filter.rentangHarga.add(h);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          width: 56,
                          height: 40,
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF8B5E2A)
                                : const Color(0xFFF5ECD7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF8B5E2A)
                                  : const Color(0xFFDDD0BC),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              h,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF8B5E2A),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // --- TOGGLE: BUKA SEKARANG ---
                  _buildToggleRow(
                    label: 'Buka Sekarang',
                    value: _filter.bukaSekarang,
                    onChanged: (v) => setState(() => _filter.bukaSekarang = v),
                  ),
                  const SizedBox(height: 12),

                  // --- TOGGLE: PROMO TERSEDIA ---
                  _buildToggleRow(
                    label: 'Promo Tersedia',
                    value: _filter.promoTersedia,
                    onChanged: (v) => setState(() => _filter.promoTersedia = v),
                  ),
                  const SizedBox(height: 32),

                  // --- TOMBOL TERAPKAN ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5E2A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, _filter),
                      icon: const Icon(Icons.check_rounded, size: 20),
                      label: const Text(
                        'Terapkan Filter',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF2C1A0E),
            fontWeight: FontWeight.w500,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFF8B5E2A),
          activeTrackColor: const Color(0xFFD4B483),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2C1A0E),
      ),
    );
  }
}

// ============================================================
// HASIL PENCARIAN PAGE
// ============================================================
class HasilPencarianPage extends StatefulWidget {
  final String initialQuery;
  final List<TempatMakanModel> allData;

  const HasilPencarianPage({
    super.key,
    required this.initialQuery,
    required this.allData,
  });

  @override
  State<HasilPencarianPage> createState() => _HasilPencarianPageState();
}

class _HasilPencarianPageState extends State<HasilPencarianPage> {
  late TextEditingController _searchCtrl;
  late List<TempatMakanModel> _filtered;
  FilterOptions _filter = FilterOptions();
  String _sortBy = 'rating'; // 'rating' | 'name' | 'distance'

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialQuery);
    _applyFilter();
  }

  void _applyFilter() {
    setState(() {
      _filtered = widget.allData.where((item) {
        final q = _searchCtrl.text.toLowerCase();
        final matchQuery = q.isEmpty ||
            item.name.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q) ||
            item.address.toLowerCase().contains(q);
        return matchQuery;
      }).toList();

      // Sort
      if (_sortBy == 'rating') {
        _filtered.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (_sortBy == 'name') {
        _filtered.sort((a, b) => a.name.compareTo(b.name));
      }
    });
  }

  void _openFilter() async {
    final result = await showModalBottomSheet<FilterOptions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => FilterPage(initialFilter: _filter),
      ),
    );
    if (result != null) {
      setState(() => _filter = result);
      _applyFilter();
    }
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Urutkan',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C1A0E))),
            const SizedBox(height: 16),
            _sortOption('Rating Tertinggi', 'rating'),
            _sortOption('Nama A–Z', 'name'),
          ],
        ),
      ),
    );
  }

  Widget _sortOption(String label, String value) {
    final selected = _sortBy == value;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: const Color(0xFF8B5E2A),
      ),
      title: Text(label,
          style: TextStyle(
              color: selected
                  ? const Color(0xFF8B5E2A)
                  : const Color(0xFF2C1A0E),
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal)),
      onTap: () {
        setState(() => _sortBy = value);
        _applyFilter();
        Navigator.pop(context);
      },
    );
  }

  String _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    String rootUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    return '$rootUrl/storage/$url';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EE),
      body: SafeArea(
        child: Column(
          children: [
            // --- Header Search ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5ECD7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_rounded,
                          color: Color(0xFF8B5E2A), size: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5ECD7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onSubmitted: (_) => _applyFilter(),
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF2C1A0E)),
                        decoration: InputDecoration(
                          hintText: 'Cari makanan atau restoran...',
                          hintStyle: TextStyle(
                              color: Colors.grey[400], fontSize: 14),
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xFFC49A5A), size: 20),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close,
                                      color: Colors.grey[400], size: 18),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    _applyFilter();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Bell
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5ECD7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.notifications_outlined,
                        color: Color(0xFF8B5E2A), size: 20),
                  ),
                ],
              ),
            ),

            // --- Sub-header: count + sort ---
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filtered.length} Restoran ditemukan',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showSortSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFDDD0BC)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.sort_rounded,
                              size: 16, color: Color(0xFF8B5E2A)),
                          SizedBox(width: 4),
                          Text('Urutkan',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8B5E2A),
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- List Hasil ---
            Expanded(
              child: _filtered.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) =>
                          _buildRestaurantCard(_filtered[i]),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openFilter,
        backgroundColor: const Color(0xFF8B5E2A),
        foregroundColor: Colors.white,
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.tune_rounded, size: 20),
            if (_filter.isActive)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        label: const Text('Filter',
            style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 4,
      ),
    );
  }

  Widget _buildRestaurantCard(TempatMakanModel item) {
    final imageUrl = _resolveImageUrl(item.imageUrl);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => DetailTempatMakanPage(tempatMakan: item)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                  // Tombol favorit
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border_rounded,
                          color: Color(0xFF8B5E2A), size: 20),
                    ),
                  ),
                  // Rating badge
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFF5A623), size: 14),
                          const SizedBox(width: 3),
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1A0E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: Color(0xFF8B5E2A)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          item.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Tags
                  Wrap(
                    spacing: 6,
                    children: [
                      _buildTag('Buka', const Color(0xFF38A169),
                          const Color(0xFFE6F4EA)),
                      _buildTag(item.description.isNotEmpty
                          ? item.description.split(' ').take(2).join(' ')
                          : 'Restoran', const Color(0xFF8B5E2A),
                          const Color(0xFFF5ECD7)),
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

  Widget _buildTag(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: textColor, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: const Color(0xFFE8D5A3),
      child: const Icon(Icons.restaurant_menu_rounded,
          size: 50, color: Color(0xFF8B5E2A)),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada restoran ditemukan',
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah kata kunci atau filter',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

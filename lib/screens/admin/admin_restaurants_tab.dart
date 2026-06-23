import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../models/tempat_makan_model.dart';
import '../../../services/tempat_makan_service.dart';

class AdminRestaurantsTab extends StatefulWidget {
  const AdminRestaurantsTab({Key? key}) : super(key: key);

  @override
  State<AdminRestaurantsTab> createState() => _AdminRestaurantsTabState();
}

class _AdminRestaurantsTabState extends State<AdminRestaurantsTab> {
  String _searchQuery = '';
  List<TempatMakanModel> _restaurants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await TempatMakanService().getTempatMakan();
      setState(() {
        _restaurants = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<TempatMakanModel> get _filtered {
    if (_searchQuery.isEmpty) return _restaurants;
    final q = _searchQuery.toLowerCase();
    return _restaurants.where((r) =>
      r.name.toLowerCase().contains(q) || r.address.toLowerCase().contains(q)).toList();
  }

  void _showAddEditDialog({TempatMakanModel? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        existing == null ? 'Tambah Tempat Makan' : 'Edit Tempat Makan',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.border),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FormField(label: 'Nama Tempat Makan *', controller: nameCtrl, hint: 'cth. Warung Makan Sederhana'),
                        const SizedBox(height: 14),
                        _FormField(label: 'Alamat *', controller: addressCtrl, hint: 'Jl. Contoh No. 1, Kota', maxLines: 2),
                        const SizedBox(height: 14),
                        _FormField(label: 'Deskripsi *', controller: descCtrl, hint: 'Deskripsi singkat tempat makan', maxLines: 4),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isSaving ? null : () async {
                              if (!formKey.currentState!.validate()) return;
                              setModalState(() => isSaving = true);
                              try {
                                if (existing != null) {
                                  await TempatMakanService().editTempatMakan(
                                    id: existing.id,
                                    name: nameCtrl.text.trim(),
                                    address: addressCtrl.text.trim(),
                                    description: descCtrl.text.trim(),
                                  );
                                } else {
                                  await TempatMakanService().addTempatMakan(
                                    name: nameCtrl.text.trim(),
                                    address: addressCtrl.text.trim(),
                                    description: descCtrl.text.trim(),
                                  );
                                }
                                Navigator.pop(ctx);
                                _showSnack(existing == null ? 'Tempat makan berhasil ditambahkan' : 'Data berhasil diperbarui', AppColors.success);
                                _loadRestaurants();
                              } catch (e) {
                                setModalState(() => isSaving = false);
                                _showSnack('Gagal menyimpan: ${e.toString()}', AppColors.error);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: isSaving
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(
                                    existing == null ? 'Tambah Sekarang' : 'Simpan Perubahan',
                                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(TempatMakanModel r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Tempat Makan', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
        content: Text('Hapus "${r.name}" dari platform? Tindakan ini tidak dapat dibatalkan.', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await TempatMakanService().deleteTempatMakan(r.id);
                _showSnack('Tempat makan berhasil dihapus', AppColors.textPrimary);
                _loadRestaurants();
              } catch (e) {
                _showSnack('Gagal menghapus: ${e.toString()}', AppColors.error);
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Hapus', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  String _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://10.0.2.2:8000/storage/$url';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text('Gagal memuat: $_error', style: GoogleFonts.poppins(color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadRestaurants, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    final list = _filtered;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search & Tambah
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(Icons.search, color: AppColors.textLight, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: InputDecoration(
                            hintText: 'Cari restoran...',
                            border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                            filled: false, contentPadding: EdgeInsets.zero,
                            hintStyle: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _showAddEditDialog(),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: Text('Tambah', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Header tabel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('Tempat Makan', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('Rating', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
                Text('Aksi', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: list.isEmpty
                ? Center(child: Text('Tidak ada data', style: GoogleFonts.poppins(color: AppColors.textLight)))
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (ctx, i) {
                      final r = list[i];
                      final resolvedUrl = _resolveImageUrl(r.imageUrl);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: resolvedUrl.isNotEmpty
                                  ? Image.network(resolvedUrl, width: 44, height: 44, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(width: 44, height: 44, color: AppColors.cardBg))
                                  : Container(width: 44, height: 44, color: AppColors.cardBg, child: const Icon(Icons.storefront, color: Colors.grey)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.name, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text(r.address, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  Text(' ${r.rating.toStringAsFixed(1)}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () => _showAddEditDialog(existing: r),
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.edit_outlined, size: 15, color: AppColors.primary),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => _confirmDelete(r),
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.delete_outline, size: 15, color: AppColors.error),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            'Menampilkan ${list.length} dari ${_restaurants.length} tempat makan',
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: InputDecoration(hintText: hint),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
        ),
      ],
    );
  }
}
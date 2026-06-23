import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../services/admin_service.dart';
import '../../../utils/constants.dart';

class AdminPhotosTab extends StatefulWidget {
  const AdminPhotosTab({Key? key}) : super(key: key);

  @override
  State<AdminPhotosTab> createState() => _AdminPhotosTabState();
}

class _AdminPhotosTabState extends State<AdminPhotosTab> {
  String _searchQuery = '';
  List<Map<String, dynamic>> _photos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await AdminService().getAllPhotos();
      setState(() {
        _photos = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_searchQuery.isEmpty) return _photos;
    final q = _searchQuery.toLowerCase();
    return _photos.where((p) {
      final uName = p['user'] != null ? (p['user']['name'] ?? '').toString().toLowerCase() : '';
      final tmName = p['tempat_makan'] != null ? (p['tempat_makan']['name'] ?? '').toString().toLowerCase() : '';
      return uName.contains(q) || tmName.contains(q);
    }).toList();
  }

  void _deletePhoto(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Foto',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Hapus foto ini secara permanen dari platform? '
          'Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await AdminService().deletePhoto(id);
                _showSnack('Foto berhasil dihapus', AppColors.textPrimary);
                _loadPhotos();
              } catch (e) {
                _showSnack('Gagal menghapus: ${e.toString()}', AppColors.error);
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showPreview(Map<String, dynamic> photo, String resolvedUrl) {
    final uName = photo['user'] != null ? photo['user']['name'] ?? 'User' : 'User';
    final tmName = photo['tempat_makan'] != null ? photo['tempat_makan']['name'] ?? 'Warung' : 'Warung';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                resolvedUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: AppColors.cardBg,
                  child: const Center(
                    child: Icon(Icons.broken_image_outlined,
                        color: AppColors.textLight, size: 40),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tmName,
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                          Text(
                            'oleh $uName',
                            style: GoogleFonts.poppins(
                                fontSize: 10, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                radius: 16,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
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
            ElevatedButton(onPressed: _loadPhotos, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    final list = _filtered;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search
          Container(
            height: 42,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border)),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.search, color: AppColors.textLight, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan warung atau pengunggah...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textLight),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Grid foto
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.photo_library_outlined,
                            size: 48, color: AppColors.textLight),
                        const SizedBox(height: 10),
                        Text('Tidak ada foto ditemukan',
                            style: GoogleFonts.poppins(
                                color: AppColors.textLight)),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: list.length,
                    itemBuilder: (ctx, i) {
                      final photo = list[i];
                      final resolvedUrl = _resolveImageUrl(photo['image_url']);
                      final uName = photo['user'] != null ? photo['user']['name'] ?? 'User' : 'User';
                      final tmName = photo['tempat_makan'] != null ? photo['tempat_makan']['name'] ?? 'Warung' : 'Warung';

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: resolvedUrl.isNotEmpty
                                          ? Image.network(
                                              resolvedUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                color: AppColors.cardBg,
                                                child: const Icon(Icons.broken_image,
                                                    color: AppColors.textLight),
                                              ),
                                            )
                                          : Container(
                                              color: AppColors.cardBg,
                                              child: const Icon(Icons.photo,
                                                  color: AppColors.textLight),
                                            ),
                                    ),
                                    Positioned.fill(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _showPreview(photo, resolvedUrl),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tmName,
                                            style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'oleh $uName',
                                            style: GoogleFonts.poppins(
                                                fontSize: 9,
                                                color: AppColors.textLight),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _deletePhoto(photo['id']),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFFEE2E2),
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        child: const Icon(
                                          Icons.delete_outline,
                                          size: 14,
                                          color: AppColors.error,
                                        ),
                                      ),
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
          ),

          const SizedBox(height: 8),
          Text(
            'Menampilkan ${list.length} dari ${_photos.length} foto',
            style: GoogleFonts.poppins(
                fontSize: 11, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}
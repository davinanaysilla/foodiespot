import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../services/admin_service.dart';

class AdminReviewsTab extends StatefulWidget {
  const AdminReviewsTab({Key? key}) : super(key: key);

  @override
  State<AdminReviewsTab> createState() => _AdminReviewsTabState();
}

class _AdminReviewsTabState extends State<AdminReviewsTab> {
  final _adminService = AdminService();
  List<Map<String, dynamic>> _reviews = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _adminService.getAllReviews();
      setState(() {
        _reviews = data;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filtered = _reviews.toList();
    } else {
      final q = _searchQuery.toLowerCase();
      _filtered = _reviews.where((r) =>
          (r['user']?['name'] ?? '').toLowerCase().contains(q) ||
          (r['comment'] ?? '').toLowerCase().contains(q) ||
          (r['tempat_makan']?['name'] ?? '').toLowerCase().contains(q)).toList();
    }
  }

  Future<void> _deleteReview(Map<String, dynamic> review) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Review',
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
        content: Text(
          'Hapus ulasan dari "${review['user']?['name'] ?? 'User'}"? Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _adminService.deleteReview(review['id']);
                _showSnack('Ulasan berhasil dihapus', AppColors.textPrimary);
                _loadReviews();
              } catch (e) {
                _showSnack(e.toString().replaceAll('Exception: ', ''), AppColors.error);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
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

  Widget _buildStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => Icon(
        i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
        size: 14,
        color: i < rating ? AppColors.star : AppColors.textLight,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: AppColors.textLight),
              const SizedBox(height: 16),
              Text('Gagal memuat review',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                  onPressed: _loadReviews,
                  icon: const Icon(Icons.refresh),
                  label: Text('Coba Lagi', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary)),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReviews,
      color: AppColors.primary,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari reviewer, komentar, atau tempat makan...',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight),
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textLight),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              ),
              onChanged: (v) => setState(() { _searchQuery = v; _applyFilter(); }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${_filtered.length} ulasan',
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight)),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Text('Tidak ada review ditemukan',
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final r = _filtered[i];
                      final rating = r['rating'] ?? 0;
                      final userName = r['user']?['name'] ?? 'User';
                      final restaurantName = r['tempat_makan']?['name'] ?? '-';
                      final comment = r['comment'] ?? '';

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(userName,
                                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                        Text('📍 $restaurantName',
                                            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  _buildStars(rating),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                    onPressed: () => _deleteReview(r),
                                  ),
                                ],
                              ),
                              if (comment.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(comment,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                              ],
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
  }
}
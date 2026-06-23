import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../services/admin_service.dart';
import '../../../models/pengajuan_owner_model.dart';

class AdminApplicationsTab extends StatefulWidget {
  const AdminApplicationsTab({Key? key}) : super(key: key);

  @override
  State<AdminApplicationsTab> createState() => _AdminApplicationsTabState();
}

class _AdminApplicationsTabState extends State<AdminApplicationsTab> {
  final _adminService = AdminService();
  List<PengajuanOwnerModel> _applications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _adminService.getPendingPengajuan();
      setState(() { _applications = data; _isLoading = false; });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _approve(PengajuanOwnerModel app) async {
    try {
      await _adminService.approvePengajuan(app.id);
      _showSnack('Pengajuan "${app.namaToko}" disetujui', AppColors.success);
      _loadApplications();
    } catch (e) {
      _showSnack(e.toString().replaceAll('Exception: ', ''), AppColors.error);
    }
  }

  Future<void> _reject(PengajuanOwnerModel app) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Tolak Pengajuan',
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
        content: Text(
          'Tolak pengajuan dari "${app.userName ?? 'User'}" untuk "${app.namaToko}"?',
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
                await _adminService.rejectPengajuan(app.id);
                _showSnack('Pengajuan ditolak', AppColors.error);
                _loadApplications();
              } catch (e) {
                _showSnack(e.toString().replaceAll('Exception: ', ''), AppColors.error);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Tolak', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(PengajuanOwnerModel app) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Pengajuan',
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
        content: Text(
          'Hapus pengajuan dari "${app.namaToko}"? Tindakan ini tidak dapat dibatalkan.',
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
                await _adminService.hapusPengajuan(app.id);
                _showSnack('Pengajuan berhasil dihapus', AppColors.textPrimary);
                _loadApplications();
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

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return AppColors.warning;
      case 'approved': return AppColors.success;
      case 'rejected': return AppColors.error;
      default: return AppColors.textLight;
    }
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
              Text('Gagal memuat pengajuan',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                  onPressed: _loadApplications,
                  icon: const Icon(Icons.refresh),
                  label: Text('Coba Lagi', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary)),
            ],
          ),
        ),
      );
    }

    if (_applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 64, color: AppColors.textLight),
            const SizedBox(height: 16),
            Text('Tidak ada pengajuan', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Semua pengajuan sudah ditangani', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadApplications,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _applications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final app = _applications[i];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(app.namaToko,
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(app.status).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(app.status.toUpperCase(),
                            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: _statusColor(app.status))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('👤 ${app.userName ?? 'Unknown'} · ${app.userEmail ?? '-'}',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  if (app.alamat != null) ...[
                    Text('📍 ${app.alamat}',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                  ],
                  Text(app.deskripsiToko,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                  if (app.status == 'pending') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _reject(app),
                            icon: const Icon(Icons.close, size: 14, color: AppColors.error),
                            label: Text('Tolak', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.error),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _approve(app),
                            icon: const Icon(Icons.check, size: 14, color: Colors.white),
                            label: Text('Setujui', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                        onPressed: () => _delete(app),
                        tooltip: 'Hapus pengajuan',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../services/admin_service.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({Key? key}) : super(key: key);

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final _adminService = AdminService();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _filterRole = 'Semua';

  final List<String> _roleOptions = ['Semua', 'user', 'owner', 'admin'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _adminService.getAllUsers();
      setState(() {
        _users = data;
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
    var list = _users.toList();
    if (_filterRole != 'Semua') {
      list = list.where((u) => u['role'] == _filterRole).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((u) =>
          (u['name'] ?? '').toLowerCase().contains(q) ||
          (u['email'] ?? '').toLowerCase().contains(q)).toList();
    }
    _filtered = list;
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Pengguna',
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
        content: Text(
          'Hapus akun "${user['name']}"? Tindakan ini tidak dapat dibatalkan.',
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
                await _adminService.deleteUser(user['id']);
                _showSnack('Pengguna "${user['name']}" dihapus', AppColors.textPrimary);
                _loadUsers();
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

  Color _roleColor(String role) {
    switch (role) {
      case 'admin': return AppColors.error;
      case 'owner': return AppColors.secondary;
      default: return AppColors.primary;
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
              Text('Gagal memuat pengguna',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                  onPressed: _loadUsers,
                  icon: const Icon(Icons.refresh),
                  label: Text('Coba Lagi', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary)),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      color: AppColors.primary,
      child: Column(
        children: [
          // Search & Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau email...',
                    hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight),
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textLight),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  ),
                  onChanged: (v) => setState(() { _searchQuery = v; _applyFilter(); }),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _roleOptions.map((r) {
                      final isSelected = _filterRole == r;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(r,
                              style: GoogleFonts.poppins(fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                  color: isSelected ? Colors.white : AppColors.textSecondary)),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.cardBg,
                          onSelected: (_) => setState(() { _filterRole = r; _applyFilter(); }),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('${_filtered.length} pengguna ditemukan',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Text('Tidak ada pengguna ditemukan',
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final user = _filtered[i];
                      final role = user['role'] ?? 'user';
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: _roleColor(role).withValues(alpha: 0.12),
                            child: Text(
                              (user['name'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: _roleColor(role)),
                            ),
                          ),
                          title: Text(user['name'] ?? '-',
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['email'] ?? '-',
                                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _roleColor(role).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(role.toUpperCase(),
                                    style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: _roleColor(role))),
                              ),
                            ],
                          ),
                          trailing: role != 'admin'
                              ? IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                  onPressed: () => _deleteUser(user),
                                )
                              : null,
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
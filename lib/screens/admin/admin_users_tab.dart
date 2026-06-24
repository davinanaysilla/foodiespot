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

  Future<void> _toggleSuspend(Map<String, dynamic> user) async {
    final isSuspended = user['is_suspended'] == true;
    final action = isSuspended ? 'Aktifkan' : 'Tangguhkan';
    final actionDesc = isSuspended
        ? 'Akun "${user['name']}" akan diaktifkan kembali dan dapat login.'
        : 'Akun "${user['name']}" akan ditangguhkan. Pengguna tidak dapat login.';
    final actionColor = isSuspended ? AppColors.success : AppColors.warning;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('$action Pengguna',
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
        content: Text(
          actionDesc,
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
                final newStatus = await _adminService.suspendUser(user['id']);
                // Update locally without full reload
                setState(() {
                  final idx = _users.indexWhere((u) => u['id'] == user['id']);
                  if (idx != -1) _users[idx]['is_suspended'] = newStatus;
                  _applyFilter();
                });
                final resultMsg = newStatus
                    ? 'Akun "${user['name']}" berhasil ditangguhkan'
                    : 'Akun "${user['name']}" berhasil diaktifkan kembali';
                _showSnack(resultMsg, newStatus ? AppColors.warning : AppColors.success);
              } catch (e) {
                _showSnack(e.toString().replaceAll('Exception: ', ''), AppColors.error);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: actionColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(action, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
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
                      final isSuspended = user['is_suspended'] == true;
                      return Container(
                        decoration: BoxDecoration(
                          color: isSuspended
                              ? AppColors.warning.withValues(alpha: 0.04)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSuspended
                                ? AppColors.warning.withValues(alpha: 0.4)
                                : AppColors.border,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: _roleColor(role).withValues(alpha: 0.12),
                                child: Text(
                                  (user['name'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: _roleColor(role)),
                                ),
                              ),
                              if (isSuspended)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: AppColors.warning,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                    child: const Icon(Icons.block, color: Colors.white, size: 8),
                                  ),
                                ),
                            ],
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                child: Text(user['name'] ?? '-',
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                    overflow: TextOverflow.ellipsis),
                              ),
                              if (isSuspended) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('SUSPENDED',
                                      style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.warning)),
                                ),
                              ],
                            ],
                          ),
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
                              ? Tooltip(
                                  message: isSuspended ? 'Aktifkan Akun' : 'Tangguhkan Akun',
                                  child: IconButton(
                                    icon: Icon(
                                      isSuspended ? Icons.lock_open_outlined : Icons.block_outlined,
                                      color: isSuspended ? AppColors.success : AppColors.warning,
                                      size: 22,
                                    ),
                                    onPressed: () => _toggleSuspend(user),
                                  ),
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
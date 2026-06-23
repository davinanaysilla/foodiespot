import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../splash/role_checker.dart';
import 'edit_profile_page.dart';
import 'notification_page.dart';
import '../dashboards/favorite_page.dart';
import '../../utils/constants.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserModel _currentUser;
  bool _isLoading = false;

  static const Color _bgColor = Color(0xFFFCF8F3);
  static const Color _primaryBrown = Color(0xFF8B5E2A);
  static const Color _textDark = Color(0xFF2C1A0E);
  static const Color _borderColor = Color(0xFFEAE0D5);

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    try {
      final updatedUser = await AuthService().fetchUserProfile();
      if (mounted) {
        setState(() {
          _currentUser = updatedUser;
        });
      }
    } catch (e) {
      debugPrint("Error refreshing profile: $e");
    }
  }

  String _resolveImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return '${ApiConfig.baseUrl.replaceAll('/api', '')}/storage/$url';
  }

  void _showDeleteAccountModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Hapus Akun Permanen?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark),
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin menghapus akun? Tindakan ini tidak dapat dibatalkan dan semua data preferensi kuliner Anda akan hilang.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Colors.transparent), // Flat look for cancel
                      ),
                      child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        setState(() => _isLoading = true);
                        try {
                          await AuthService().deleteAccount();
                          if (!mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const RoleChecker()),
                            (route) => false,
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Hapus Akun', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEditProfile() async {
    final updatedUser = await Navigator.push<UserModel>(
      context,
      MaterialPageRoute(builder: (_) => EditProfilePage(user: _currentUser)),
    );
    if (updatedUser != null && mounted) {
      setState(() {
        _currentUser = updatedUser;
      });
    }
  }

  void _navigateToNotifications() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage()));
  }

  void _navigateToFavorites() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritePage()));
  }

  Widget _buildAvatar() {
    if (_currentUser.photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: _borderColor,
        backgroundImage: NetworkImage(_resolveImageUrl(_currentUser.photoUrl)),
        onBackgroundImageError: (exception, stackTrace) {},
      );
    }
    return CircleAvatar(
      radius: 40,
      backgroundColor: _primaryBrown,
      child: Text(
        _currentUser.name.isNotEmpty ? _currentUser.name[0].toUpperCase() : 'U',
        style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: _bgColor, body: Center(child: CircularProgressIndicator(color: _primaryBrown)));
    }

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text('Profil', style: TextStyle(color: _textDark, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: _textDark),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Avatar Profile
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _borderColor, width: 2)),
                    child: _buildAvatar(),
                  ),
                  GestureDetector(
                    onTap: _navigateToEditProfile,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: _primaryBrown, shape: BoxShape.circle, border: Border.all(color: _bgColor, width: 2)),
                      child: const Icon(Icons.edit, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // User Info
            Text(_currentUser.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textDark)),
            const SizedBox(height: 4),
            Text(_currentUser.email, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 12),
                  const SizedBox(width: 4),
                  Text('Pengguna Aktif', style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildStatBox(_currentUser.reviewsCount.toString(), 'Total\nUlasan'),
                  const SizedBox(width: 12),
                  _buildStatBox(_currentUser.photosCount.toString(), 'Foto'),
                  const SizedBox(width: 12),
                  _buildStatBox(_currentUser.favoritesCount.toString(), 'Favorit'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Menu List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _borderColor),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(Icons.person_outline, 'Edit Profil', onTap: _navigateToEditProfile),
                    _buildDivider(),
                    // Menu Favorit akan memberitahu user untuk pindah tab (karena Favorit adalah Tab)
                    // Atau bisa juga redirect ke halaman Favorit standalone
                    _buildMenuItem(Icons.favorite_border, 'Daftar Favorit', onTap: _navigateToFavorites),
                    _buildDivider(),
                    _buildMenuItem(Icons.notifications_outlined, 'Notifikasi', onTap: _navigateToNotifications, hasRedDot: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _borderColor),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(Icons.storefront_outlined, 'Ajukan Jadi Pemilik', subtitle: 'Kelola restoran Anda sendiri di sini'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _borderColor),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(Icons.logout, 'Keluar', onTap: () async {
                      await AuthService().signOut();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const RoleChecker()), (route) => false);
                    }),
                    _buildDivider(),
                    _buildMenuItem(Icons.delete_outline, 'Hapus Akun', isDestructive: true, onTap: _showDeleteAccountModal),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String number, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
        ),
        child: Column(
          children: [
            Text(number, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {String? subtitle, bool hasRedDot = false, bool isDestructive = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive ? Colors.red.shade50 : const Color(0xFFF9F5EF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFFC49A5A), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDestructive ? Colors.red : _textDark)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ]
                ],
              ),
            ),
            if (hasRedDot)
              Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 64, color: Colors.grey.shade100);
  }
}


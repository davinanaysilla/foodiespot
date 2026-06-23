import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../models/dummy_data.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  File? _avatarFile;

  Future<void> _pickAvatar() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Ubah Foto Profil', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _PhotoOption(
                  icon: Icons.camera_alt,
                  label: 'Kamera',
                  color: AppColors.primary,
                  onTap: () async {
                    Navigator.pop(ctx);
                    final img = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
                    if (img != null) setState(() => _avatarFile = File(img.path));
                  },
                )),
                const SizedBox(width: 12),
                Expanded(child: _PhotoOption(
                  icon: Icons.photo_library,
                  label: 'Galeri',
                  color: AppColors.secondary,
                  onTap: () async {
                    Navigator.pop(ctx);
                    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
                    if (img != null) setState(() => _avatarFile = File(img.path));
                  },
                )),
                if (_avatarFile != null) ...[
                  const SizedBox(width: 12),
                  Expanded(child: _PhotoOption(
                    icon: Icons.delete_outline,
                    label: 'Hapus',
                    color: AppColors.error,
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() => _avatarFile = null);
                    },
                  )),
                ],
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = DummyData.currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('Profil Saya', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Avatar
                      GestureDetector(
                        onTap: _pickAvatar,
                        child: Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                color: AppColors.cardBg,
                              ),
                              child: ClipOval(
                                child: _avatarFile != null
                                    ? Image.file(_avatarFile!, fit: BoxFit.cover)
                                    : Center(
                                        child: Text(
                                          user.name.substring(0, 2).toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, size: 13, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(user.name, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text(user.email, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
                        ),
                        child: Text('Pengguna Aktif', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Stats
                  const Row(
                    children: [
                      _ProfileStat(icon: Icons.star, value: '12', label: 'Ulasan', color: AppColors.star),
                      SizedBox(width: 12),
                      _ProfileStat(icon: Icons.favorite, value: '8', label: 'Favorit', color: Colors.red),
                      SizedBox(width: 12),
                      _ProfileStat(icon: Icons.photo, value: '2', label: 'Foto', color: AppColors.secondary),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.07), blurRadius: 10, offset: const Offset(0, 3))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Informasi Akun', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const Divider(height: 16, color: AppColors.border),
                        _InfoItem('Nama', user.name),
                        _InfoItem('Email', user.email),
                        _InfoItem('No. HP', user.phone),
                        _InfoItem('Bergabung', user.joinDate),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Menu items
                  _MenuCard(
                    icon: Icons.edit_outlined,
                    label: 'Edit Profil',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                  ),
                  _MenuCard(
                    icon: Icons.star_outline,
                    label: 'Review Saya',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyReviewsScreen())),
                  ),
                  _MenuCard(
                    icon: Icons.photo_library_outlined,
                    label: 'Foto Saya',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPhotosScreen())),
                  ),
                  const SizedBox(height: 8),
                  _MenuCard(
                    icon: Icons.logout,
                    label: 'Keluar',
                    color: AppColors.error,
                    onTap: () => showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text('Keluar?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                        content: Text('Apakah Anda yakin ingin keluar dari akun?', style: GoogleFonts.poppins(fontSize: 13)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            ),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                            child: Text('Keluar', style: GoogleFonts.poppins(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PhotoOption({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _ProfileStat({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            Text(label, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight))),
          Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuCard({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: c),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: c))),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

// =================== EDIT PROFILE ===================
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  final _passwordCtrl = TextEditingController();
  File? _avatar;

  @override
  void initState() {
    super.initState();
    final u = DummyData.currentUser;
    _nameCtrl = TextEditingController(text: u.name);
    _emailCtrl = TextEditingController(text: u.email);
    _phoneCtrl = TextEditingController(text: u.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Edit Profil', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Center(
              child: GestureDetector(
                onTap: () async {
                  final img = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (img != null) setState(() => _avatar = File(img.path));
                },
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.cardBg,
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      child: ClipOval(
                        child: _avatar != null
                            ? Image.file(_avatar!, fit: BoxFit.cover)
                            : Center(
                                child: Text(
                                  DummyData.currentUser.name.substring(0, 2).toUpperCase(),
                                  style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 26, height: 26,
                        decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                        child: const Icon(Icons.camera_alt, size: 13, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            _FormField(label: 'Nama Lengkap', controller: _nameCtrl),
            const SizedBox(height: 16),
            _FormField(label: 'Email', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _FormField(label: 'No. HP', controller: _phoneCtrl, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _FormField(label: 'Password Baru', controller: _passwordCtrl, obscure: true, hint: 'Kosongkan jika tidak diubah'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profil berhasil disimpan!', style: GoogleFonts.poppins(color: Colors.white)),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text('Simpan Perubahan', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscure;
  final String? hint;

  const _FormField({required this.label, required this.controller, this.keyboardType, this.obscure = false, this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          decoration: InputDecoration(hintText: hint ?? label),
        ),
      ],
    );
  }
}

// =================== MY REVIEWS ===================
class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final myReviews = DummyData.reviews.where((r) => r.userId == DummyData.currentUser.id).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Review Saya', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700))),
      body: myReviews.isEmpty
          ? Center(child: Text('Belum ada review', style: GoogleFonts.poppins(color: AppColors.textLight)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myReviews.length,
              itemBuilder: (ctx, i) => ReviewCard(review: myReviews[i]),
            ),
    );
  }
}

// =================== MY PHOTOS ===================
class MyPhotosScreen extends StatefulWidget {
  const MyPhotosScreen({Key? key}) : super(key: key);

  @override
  State<MyPhotosScreen> createState() => _MyPhotosScreenState();
}

class _MyPhotosScreenState extends State<MyPhotosScreen> {
  final List<String> _photos = [
    'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400',
    'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400',
  ];

  Future<void> _addPhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(child: _PhotoOption(icon: Icons.camera_alt, label: 'Kamera', color: AppColors.primary,
              onTap: () async {
                Navigator.pop(ctx);
                final img = await ImagePicker().pickImage(source: ImageSource.camera);
                if (img != null) setState(() => _photos.add(img.path));
              })),
            const SizedBox(width: 12),
            Expanded(child: _PhotoOption(icon: Icons.photo_library, label: 'Galeri', color: AppColors.secondary,
              onTap: () async {
                Navigator.pop(ctx);
                final img = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (img != null) setState(() => _photos.add(img.path));
              })),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Foto Saya', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
        actions: [
          TextButton.icon(
            onPressed: _addPhoto,
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: Text('Upload', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
      body: _photos.isEmpty
          ? Center(child: Text('Belum ada foto', style: GoogleFonts.poppins(color: AppColors.textLight)))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: _photos.length,
              itemBuilder: (ctx, i) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _photos[i].startsWith('http')
                        ? Image.network(_photos[i], fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                            errorBuilder: (c, _, __) => Container(color: AppColors.cardBg))
                        : Image.file(File(_photos[i]), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                  ),
                  Positioned(
                    top: 4, right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _photos.removeAt(i)),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bioCtrl;
  
  bool _isLoading = false;
  File? _selectedPhoto;

  static const Color _primaryBrown = Color(0xFF8B5E2A);
  static const Color _bgColor = Color(0xFFFCF8F3);
  static const Color _textDark = Color(0xFF2C1A0E);
  static const Color _borderColor = Color(0xFFEAE0D5);

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _phoneCtrl = TextEditingController(text: widget.user.phone);
    _bioCtrl = TextEditingController(text: "Pencinta kuliner sejati dari Jakarta. Selalu mencari hidden gem di akhir pekan!"); // Mock bio
  }

  String _resolveImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return '${ApiConfig.baseUrl.replaceAll('/api', '')}/storage/$url';
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
    if (pickedFile != null) {
      setState(() => _selectedPhoto = File(pickedFile.path));
    }
  }

  void _handleUpdate() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama tidak boleh kosong!'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final updatedUser = await AuthService().updateProfile(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        photoFile: _selectedPhoto,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green));
      Navigator.pop(context, updatedUser); // Return updated user
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildAvatar() {
    if (_selectedPhoto != null) {
      return CircleAvatar(radius: 45, backgroundImage: FileImage(_selectedPhoto!));
    }
    if (widget.user.photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 45,
        backgroundColor: _borderColor,
        backgroundImage: NetworkImage(_resolveImageUrl(widget.user.photoUrl)),
      );
    }
    return CircleAvatar(
      radius: 45,
      backgroundColor: _primaryBrown,
      child: Text(
        widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : 'U',
        style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profil', style: TextStyle(color: _textDark, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar with edit button
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
                    onTap: _pickPhoto,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: _primaryBrown, shape: BoxShape.circle, border: Border.all(color: _bgColor, width: 2)),
                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Form Fields
            _buildInputField('Nama Lengkap', Icons.person_outline, _nameCtrl),
            const SizedBox(height: 20),
            
            // Email (Disabled)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('Email ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
                    Text('(Tidak dapat diubah)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: TextEditingController(text: widget.user.email),
                  enabled: false,
                  style: const TextStyle(color: Colors.grey),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey, size: 20),
                    suffixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 18),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            _buildInputField('Nomor Telepon', Icons.phone_android_outlined, _phoneCtrl, keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            
            _buildInputField('Bio Singkat', Icons.description_outlined, _bioCtrl, maxLines: 3, hint: 'Ceritakan sedikit tentang Anda...'),
            const SizedBox(height: 40),

            // Save Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleUpdate,
              icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.save_outlined, color: Colors.white, size: 20),
              label: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBrown,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: _textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.grey, size: 20) : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primaryBrown, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

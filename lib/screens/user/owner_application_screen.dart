// lib/screens/user/owner_application_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/dummy_data.dart';

// =============================================================
// SCREEN UTAMA — menentukan tampilan form atau status pengajuan
// =============================================================
class OwnerApplicationScreen extends StatefulWidget {
  const OwnerApplicationScreen({Key? key}) : super(key: key);

  @override
  State<OwnerApplicationScreen> createState() => _OwnerApplicationScreenState();
}

class _OwnerApplicationScreenState extends State<OwnerApplicationScreen> {
  // Ambil pengajuan aktif milik user yang sedang login
  OwnerApplicationModel? get _application =>
      DummyData.getActiveApplicationFor(DummyData.currentUser.id);

  @override
  Widget build(BuildContext context) {
    final application = _application;

    // Tampilkan form jika belum ada pengajuan atau pengajuan sebelumnya ditolak
    final showForm = application == null || application.status == 'rejected';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(showForm),
          Expanded(
            child: showForm
                ? _ApplicationForm(
                    rejectedApplication: application,
                    onSubmitted: () => setState(() {}), // Refresh setelah submit
                  )
                : _ApplicationStatus(
                    application: application,
                    onCancelled: () => setState(() {}), // Refresh setelah batal
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool showForm) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            children: [
              // Tombol kembali
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Judul header berubah sesuai kondisi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showForm ? 'Pengajuan Owner' : 'Status Pengajuan',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      showForm
                          ? 'Daftarkan tempat makan Anda'
                          : 'Pantau status pengajuan Anda',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Ikon dekoratif kanan
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// BAGIAN CREATE — Form pengajuan owner baru
// =============================================================
class _ApplicationForm extends StatefulWidget {
  final OwnerApplicationModel? rejectedApplication; // Tidak null jika sebelumnya ditolak
  final VoidCallback onSubmitted;

  const _ApplicationForm({
    this.rejectedApplication,
    required this.onSubmitted,
  });

  @override
  State<_ApplicationForm> createState() => _ApplicationFormState();
}

class _ApplicationFormState extends State<_ApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Masakan Jawa',
    'Masakan Rumahan',
    'Western Food',
    'Sate & Grill',
    'Cafe & Kopi',
    'Seafood',
    'Lainnya',
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ---- Logika submit (CREATE) ----
  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Silakan pilih kategori bisnis terlebih dahulu',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1000)); // Simulasi request API
    if (!mounted) return;

    // Simpan pengajuan ke data sementara (dummy)
    DummyData.ownerApplications.add(
      OwnerApplicationModel(
        id: 'app${DummyData.ownerApplications.length + 1}',
        userId: DummyData.currentUser.id,
        applicantName: DummyData.currentUser.name,
        businessName: _businessNameController.text.trim(),
        category: _selectedCategory!,
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        description: _descriptionController.text.trim(),
        status: 'pending',
        submittedDate: DateTime.now().toIso8601String().substring(0, 10),
      ),
    );

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Pengajuan berhasil dikirim',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    // Beri tahu parent agar refresh tampilan ke halaman status
    widget.onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner peringatan jika pengajuan sebelumnya ditolak
            if (widget.rejectedApplication != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.error, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pengajuan sebelumnya ditolak',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                            ),
                          ),
                          if (widget.rejectedApplication!.note != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.rejectedApplication!.note!,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            'Anda dapat memperbaiki data dan mengajukan kembali.',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ---- Field: Nama Tempat Makan ----
            const _FieldLabel('Nama Tempat Makan'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _businessNameController,
              decoration: const InputDecoration(
                hintText: 'cth. Warung Makan Sari Rasa',
                prefixIcon: Icon(
                  Icons.store_outlined,
                  color: AppColors.textLight,
                  size: 20,
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty)
                      ? 'Nama tempat makan wajib diisi'
                      : null,
            ),
            const SizedBox(height: 18),

            // ---- Field: Kategori (Dropdown) ----
            const _FieldLabel('Kategori'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textLight,
              ),
              decoration: const InputDecoration(
                hintText: 'Pilih kategori bisnis',
                prefixIcon: Icon(
                  Icons.category_outlined,
                  color: AppColors.textLight,
                  size: 20,
                ),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          c,
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 18),

            // ---- Field: Alamat Lengkap ----
            const _FieldLabel('Alamat Lengkap'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Jl. Contoh No. 12, Kelurahan, Kecamatan, Kota',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: AppColors.textLight,
                    size: 20,
                  ),
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Alamat wajib diisi' : null,
            ),
            const SizedBox(height: 18),

            // ---- Field: Nomor Telepon Bisnis ----
            const _FieldLabel('Nomor Telepon Bisnis'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'cth. 0812-3456-7890',
                prefixIcon: Icon(
                  Icons.phone_outlined,
                  color: AppColors.textLight,
                  size: 20,
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty)
                      ? 'Nomor telepon wajib diisi'
                      : null,
            ),
            const SizedBox(height: 18),

            // ---- Field: Deskripsi Singkat ----
            const _FieldLabel('Deskripsi Singkat'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Ceritakan tentang tempat makan Anda, menu andalan, jam operasional, dll.',
                alignLabelWithHint: true,
                contentPadding: EdgeInsets.all(16),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty)
                      ? 'Deskripsi wajib diisi'
                      : null,
            ),
            const SizedBox(height: 18),

            // ---- Info box verifikasi ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.secondary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                'Pengajuan Anda akan diverifikasi oleh tim FoodieSpot dalam ',
                          ),
                          TextSpan(
                            text: '2-3 hari kerja',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const TextSpan(
                            text:
                                '. Pastikan informasi yang diisi sudah benar dan lengkap.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ---- Tombol Submit ----
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_outlined,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            'Ajukan Sekarang',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Widget helper label field dengan tanda wajib (*)
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        children: [
          TextSpan(text: label),
          TextSpan(
            text: ' *',
            style: GoogleFonts.poppins(color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// BAGIAN READ + DELETE — Menampilkan status & opsi batalkan
// =============================================================
class _ApplicationStatus extends StatelessWidget {
  final OwnerApplicationModel application;
  final VoidCallback onCancelled;

  const _ApplicationStatus({
    required this.application,
    required this.onCancelled,
  });

  // Warna berdasarkan status
  Color get _statusColor {
    switch (application.status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  // Ikon berdasarkan status
  IconData get _statusIcon {
    switch (application.status) {
      case 'approved':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_top_outlined;
    }
  }

  // Label teks status
  String get _statusLabel {
    switch (application.status) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Menunggu Verifikasi';
    }
  }

  // Deskripsi penjelas status
  String get _statusDescription {
    switch (application.status) {
      case 'approved':
        return 'Selamat, pengajuan Anda telah disetujui. '
            'Anda kini dapat mengakses fitur Pemilik Warung.';
      case 'rejected':
        return 'Mohon maaf, pengajuan Anda belum dapat disetujui. '
            'Anda dapat mengajukan kembali dengan data yang sesuai.';
      default:
        return 'Pengajuan Anda sedang ditinjau oleh tim FoodieSpot. '
            'Proses verifikasi membutuhkan waktu 2-3 hari kerja.';
    }
  }

  // ---- Dialog konfirmasi pembatalan (DELETE) ----
  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Batalkan Pengajuan',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan pengajuan owner ini? '
          'Tindakan ini tidak dapat diurungkan.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Kembali',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Hapus pengajuan dari data (DELETE)
              DummyData.ownerApplications
                  .removeWhere((a) => a.id == application.id);
              Navigator.pop(ctx);
              onCancelled(); // Refresh tampilan ke form
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Pengajuan berhasil dibatalkan',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  backgroundColor: AppColors.textPrimary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Batalkan',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Kartu status utama (READ) ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Ikon status
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_statusIcon, color: _statusColor, size: 32),
                ),
                const SizedBox(height: 14),
                // Badge status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Deskripsi status
                Text(
                  _statusDescription,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                // Catatan penolakan (jika ada)
                if (application.status == 'rejected' &&
                    application.note != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Catatan: ${application.note}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.error,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ---- Detail pengajuan (READ) ----
          Text(
            'Detail Pengajuan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _DetailRow(
                  label: 'Nama Tempat Makan',
                  value: application.businessName,
                ),
                _DetailRow(
                  label: 'Kategori',
                  value: application.category,
                ),
                _DetailRow(
                  label: 'Alamat',
                  value: application.address,
                ),
                _DetailRow(
                  label: 'No. Telepon Bisnis',
                  value: application.phone,
                ),
                _DetailRow(
                  label: 'Deskripsi',
                  value: application.description,
                ),
                _DetailRow(
                  label: 'Tanggal Pengajuan',
                  value: application.submittedDate,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ---- Tombol Batalkan (DELETE) — hanya muncul saat pending ----
          if (application.status == 'pending')
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmCancel(context),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 18,
                ),
                label: Text(
                  'Batalkan Pengajuan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

          // ---- Tombol Ajukan Kembali — muncul setelah ditolak ----
          if (application.status == 'rejected')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Hapus record lama lalu tampilkan form baru
                  DummyData.ownerApplications
                      .removeWhere((a) => a.id == application.id);
                  onCancelled();
                },
                icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                label: Text(
                  'Ajukan Kembali',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Widget helper baris detail pengajuan
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
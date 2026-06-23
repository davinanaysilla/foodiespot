import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import '../../models/pengajuan_owner_model.dart';
import '../splash/role_checker.dart';
import '../../utils/constants.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Futures untuk setiap tab
  late Future<Map<String, dynamic>> _dashboardFuture;
  late Future<List<PengajuanOwnerModel>> _pengajuanFuture;
  late Future<List<Map<String, dynamic>>> _userFuture;
  late Future<List<Map<String, dynamic>>> _reviewFuture;
  late Future<List<Map<String, dynamic>>> _photoFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      // Reload data setiap kali tab berganti
      setState(() {});
    });
    _fetchAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _fetchAll() {
    setState(() {
      _dashboardFuture = AdminService().getDashboard();
      _pengajuanFuture = AdminService().getPendingPengajuan();
      _userFuture = AdminService().getAllUsers();
      _reviewFuture = AdminService().getAllReviews();
      _photoFuture = AdminService().getAllPhotos();
    });
  }

  String _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    final root = ApiConfig.baseUrl.replaceAll('/api', '');
    return '$root/storage/$url';
  }

  void _snackbar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  // ============================================================
  // TAB 1 — DASHBOARD SISTEM
  // ============================================================
  Widget _buildDashboardTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return _errorWidget(snap.error.toString(), _fetchAll);
        }
        final data = snap.data!;
        final statUser = data['statistik_user'] as Map<String, dynamic>? ?? {};
        final statTM = data['statistik_tempat_makan'] as Map<String, dynamic>? ?? {};
        final statReview = data['statistik_review'] as Map<String, dynamic>? ?? {};
        final statFoto = data['statistik_foto'] as Map<String, dynamic>? ?? {};
        final statPengajuan = data['statistik_pengajuan'] as Map<String, dynamic>? ?? {};
        final aktivitas = data['aktivitas_terbaru'] as Map<String, dynamic>? ?? {};
        final reviewTerbaru = aktivitas['review_terbaru'] as List? ?? [];
        final userBaru = aktivitas['user_baru'] as List? ?? [];

        return RefreshIndicator(
          onRefresh: () async => _fetchAll(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle('Statistik User'),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.6,
                children: [
                  _statCard('Total User', '${statUser['total_user'] ?? 0}', Icons.people, Colors.blue),
                  _statCard('Total Owner', '${statUser['total_owner'] ?? 0}', Icons.store, Colors.green),
                  _statCard('Suspended', '${statUser['total_suspended'] ?? 0}', Icons.block, Colors.red),
                  _statCard('Total Semua', '${statUser['total_semua'] ?? 0}', Icons.group, Colors.purple),
                ],
              ),
              const SizedBox(height: 20),
              _sectionTitle('Statistik Platform'),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.3,
                children: [
                  _statCard('Restoran', '${statTM['total'] ?? 0}', Icons.storefront, Colors.teal),
                  _statCard('Review', '${statReview['total'] ?? 0}', Icons.rate_review, Colors.orange),
                  _statCard('Foto', '${statFoto['total'] ?? 0}', Icons.photo, Colors.pink),
                ],
              ),
              const SizedBox(height: 20),
              _sectionTitle('Pengajuan Owner'),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _pengajuanChip('Pending', statPengajuan['pending'] ?? 0, Colors.orange),
                      _pengajuanChip('Approved', statPengajuan['approved'] ?? 0, Colors.green),
                      _pengajuanChip('Rejected', statPengajuan['rejected'] ?? 0, Colors.red),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (userBaru.isNotEmpty) ...[
                _sectionTitle('User Terbaru'),
                const SizedBox(height: 8),
                ...userBaru.take(5).map((u) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      (u['name'] ?? 'U').toString().isNotEmpty
                          ? (u['name'] as String)[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(u['name'] ?? '-'),
                  subtitle: Text(u['email'] ?? '-'),
                  trailing: Chip(
                    label: Text(u['role'] ?? '-'),
                    backgroundColor: Colors.blue[50],
                  ),
                )),
                const SizedBox(height: 20),
              ],
              if (reviewTerbaru.isNotEmpty) ...[
                _sectionTitle('Review Terbaru'),
                const SizedBox(height: 8),
                ...reviewTerbaru.take(5).map((r) {
                  final user = r['user'] as Map<String, dynamic>? ?? {};
                  final tm = r['tempat_makan'] as Map<String, dynamic>? ?? {};
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(user['name'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📍 ${tm['name'] ?? '-'}'),
                          Text(r['comment'] ?? '-', maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                      trailing: Chip(
                        label: Text('${r['rating']} ⭐'),
                        backgroundColor: Colors.amber[100],
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _pengajuanChip(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  // ============================================================
  // TAB 2 — PENGAJUAN OWNER
  // ============================================================
  Widget _buildPengajuanTab() {
    return FutureBuilder<List<PengajuanOwnerModel>>(
      future: _pengajuanFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return _errorWidget(snap.error.toString(), _fetchAll);
        }
        if (!snap.hasData || snap.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                SizedBox(height: 16),
                Text('Tidak ada antrean.', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _fetchAll(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snap.data!.length,
            itemBuilder: (context, index) {
              final item = snap.data![index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.storefront, color: Colors.white),
                  ),
                  title: Text(item.namaToko, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Pemohon: ${item.userName ?? '-'}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDetailModal(item),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showDetailModal(PengajuanOwnerModel item) {
    bool isProcessing = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, controller) => Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 50, height: 5,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 20),
                  const Text('Detail Pengajuan Mitra', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Divider(height: 32, thickness: 1),
                  Expanded(
                    child: ListView(
                      controller: controller,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
                          title: Text(item.userName ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(item.userEmail ?? ''),
                        ),
                        const SizedBox(height: 16),
                        const Text('Data Toko', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(item.namaToko, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.location_on, size: 18, color: Colors.red),
                          const SizedBox(width: 4),
                          Expanded(child: Text(item.alamat ?? 'Alamat tidak diisi')),
                        ]),
                        const SizedBox(height: 12),
                        const Text('Deskripsi:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(item.deskripsiToko),
                        const SizedBox(height: 24),
                        const Text('Dokumen KTP:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 8),
                        if (item.ktpPath != null && item.ktpPath!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(_resolveImageUrl(item.ktpPath), fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 150, color: Colors.grey[200],
                                child: const Center(child: Text('Gagal memuat gambar')),
                              ),
                            ),
                          )
                        else
                          Container(
                            height: 150,
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                            child: const Center(child: Text('KTP tidak dilampirkan')),
                          ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                  if (isProcessing)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  setModalState(() => isProcessing = true);
                                  try {
                                    await AdminService().rejectPengajuan(item.id);
                                    if (!ctx.mounted || !mounted) return;
                                    Navigator.pop(ctx);
                                    _snackbar('Pengajuan ditolak.', Colors.red);
                                    _fetchAll();
                                  } catch (e) {
                                    if (!mounted) return;
                                    _snackbar(e.toString(), Colors.red);
                                    setModalState(() => isProcessing = false);
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(color: Colors.red),
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Tolak', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  setModalState(() => isProcessing = true);
                                  try {
                                    await AdminService().approvePengajuan(item.id);
                                    if (!ctx.mounted || !mounted) return;
                                    Navigator.pop(ctx);
                                    _snackbar('Berhasil disetujui! User menjadi Owner.', Colors.green);
                                    _fetchAll();
                                  } catch (e) {
                                    if (!mounted) return;
                                    _snackbar(e.toString(), Colors.red);
                                    setModalState(() => isProcessing = false);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('SETUJUI', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            try {
                              await AdminService().hapusPengajuan(item.id);
                              if (!mounted) return;
                              _snackbar('Pengajuan berhasil dihapus.', Colors.orange);
                              _fetchAll();
                            } catch (e) {
                              if (!mounted) return;
                              _snackbar(e.toString(), Colors.red);
                            }
                          },
                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                          label: const Text('Hapus Permanen', style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // ============================================================
  // TAB 3 — MANAJEMEN USER
  // ============================================================
  Widget _buildUserTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _userFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return _errorWidget(snap.error.toString(), _fetchAll);
        }
        if (!snap.hasData || snap.data!.isEmpty) {
          return const Center(child: Text('Tidak ada user.'));
        }

        return RefreshIndicator(
          onRefresh: () async => _fetchAll(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snap.data!.length,
            itemBuilder: (context, index) {
              final u = snap.data![index];
              final role = u['role'] as String? ?? 'user';
              final roleColor = role == 'owner' ? Colors.green : role == 'admin' ? Colors.blue : Colors.grey;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: roleColor.withOpacity(0.15),
                    child: Text(
                      (u['name'] ?? 'U').toString().isNotEmpty
                          ? (u['name'] as String)[0].toUpperCase()
                          : 'U',
                      style: TextStyle(fontWeight: FontWeight.bold, color: roleColor),
                    ),
                  ),
                  title: Text(u['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(u['email'] ?? '-'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(role.toUpperCase(), style: const TextStyle(fontSize: 10)),
                        backgroundColor: roleColor.withOpacity(0.1),
                        padding: EdgeInsets.zero,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _konfirmasiHapusUser(u['id'] as int, u['name'] as String? ?? '-'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _konfirmasiHapusUser(int id, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus User?'),
        content: Text("Hapus akun '$nama' secara permanen?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await AdminService().deleteUser(id);
                if (!mounted) return;
                _snackbar('User berhasil dihapus.', Colors.orange);
                _fetchAll();
              } catch (e) {
                if (!mounted) return;
                _snackbar(e.toString(), Colors.red);
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 4 — MODERASI REVIEW
  // ============================================================
  Widget _buildReviewTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _reviewFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return _errorWidget(snap.error.toString(), _fetchAll);
        }
        if (!snap.hasData || snap.data!.isEmpty) {
          return const Center(child: Text('Tidak ada review.'));
        }

        return RefreshIndicator(
          onRefresh: () async => _fetchAll(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snap.data!.length,
            itemBuilder: (context, index) {
              final r = snap.data![index];
              final user = r['user'] as Map<String, dynamic>? ?? {};
              final tm = r['tempat_makan'] as Map<String, dynamic>? ?? {};
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange[100],
                    child: Text(
                      (user['name'] ?? 'U').toString().isNotEmpty
                          ? (user['name'] as String)[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(user['name'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      Row(
                        children: List.generate(
                          (r['rating'] ?? 0) as int,
                          (_) => const Icon(Icons.star, size: 12, color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📍 ${tm['name'] ?? '-'}', style: const TextStyle(fontSize: 12)),
                      Text(r['comment'] ?? '-', maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _konfirmasiHapusReview(r['id'] as int),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _konfirmasiHapusReview(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Review?'),
        content: const Text('Review ini akan dihapus secara permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await AdminService().deleteReview(id);
                if (!mounted) return;
                _snackbar('Review berhasil dihapus.', Colors.orange);
                _fetchAll();
              } catch (e) {
                if (!mounted) return;
                _snackbar(e.toString(), Colors.red);
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 5 — MODERASI FOTO
  // ============================================================
  Widget _buildFotoTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _photoFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return _errorWidget(snap.error.toString(), _fetchAll);
        }
        if (!snap.hasData || snap.data!.isEmpty) {
          return const Center(child: Text('Tidak ada foto.'));
        }

        return RefreshIndicator(
          onRefresh: () async => _fetchAll(),
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemCount: snap.data!.length,
            itemBuilder: (context, index) {
              final p = snap.data![index];
              final user = p['user'] as Map<String, dynamic>? ?? {};
              final tm = p['tempat_makan'] as Map<String, dynamic>? ?? {};
              final imgUrl = _resolveImageUrl(p['image_url'] as String? ?? p['image_path'] as String?);
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: imgUrl.isNotEmpty
                              ? Image.network(imgUrl, width: double.infinity, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                  ),
                                )
                              : Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.photo, size: 40, color: Colors.grey),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tm['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text('Oleh: ${user['name'] ?? '-'}', style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _konfirmasiHapusFoto(p['id'] as int),
                        child: Container(
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.delete, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _konfirmasiHapusFoto(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Foto?'),
        content: const Text('Foto ini akan dihapus secara permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await AdminService().deletePhoto(id);
                if (!mounted) return;
                _snackbar('Foto berhasil dihapus.', Colors.orange);
                _fetchAll();
              } catch (e) {
                if (!mounted) return;
                _snackbar(e.toString(), Colors.red);
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================
  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _errorWidget(String err, VoidCallback retry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text(err, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: retry, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal Admin'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RoleChecker()),
                (route) => false,
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard, size: 18), text: 'Dashboard'),
            Tab(icon: Icon(Icons.assignment, size: 18), text: 'Pengajuan'),
            Tab(icon: Icon(Icons.people, size: 18), text: 'Users'),
            Tab(icon: Icon(Icons.rate_review, size: 18), text: 'Review'),
            Tab(icon: Icon(Icons.photo_library, size: 18), text: 'Foto'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildPengajuanTab(),
          _buildUserTab(),
          _buildReviewTab(),
          _buildFotoTab(),
        ],
      ),
    );
  }
}

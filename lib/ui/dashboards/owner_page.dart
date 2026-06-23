import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/tempat_makan_service.dart';
import '../../services/owner_service.dart';
import '../../models/tempat_makan_model.dart';
import '../splash/role_checker.dart';
import '../tempat_makan/add_tempat_makan_page.dart';
import '../tempat_makan/edit_tempat_makan_page.dart';
import '../tempat_makan/detail_tempat_makan_page.dart';

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<TempatMakanModel>> _myTempatMakanFuture;
  late Future<Map<String, dynamic>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _fetchData() {
    setState(() {
      _myTempatMakanFuture = TempatMakanService().getMyTempatMakan();
      _dashboardFuture = OwnerService().getDashboard();
    });
  }

  String _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://10.0.2.2:8000/storage/$url';
  }

  void _konfirmasiHapus(int id, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Warung?'),
        content: Text(
          "Yakin ingin menutup '$nama' secara permanen? Semua foto dan review juga akan lenyap.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await TempatMakanService().deleteTempatMakan(id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Warung berhasil ditutup.'),
                    backgroundColor: Colors.orange,
                  ),
                );
                _fetchData();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Ya, Tutup Warung',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------
  // TAB 1: Daftar Warung Saya
  // --------------------------------------------------------
  Widget _buildWarungTab() {
    return FutureBuilder<List<TempatMakanModel>>(
      future: _myTempatMakanFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Gagal memuat: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store_mall_directory_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'Anda belum mendaftarkan warung.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddTempatMakanPage()),
                    );
                    if (result == true) _fetchData();
                  },
                  icon: const Icon(Icons.add_business),
                  label: const Text('Daftarkan Warung'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        final listWarung = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async => _fetchData(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: listWarung.length,
            itemBuilder: (context, index) {
              final item = listWarung[index];
              final imageUrl = _resolveImageUrl(item.imageUrl);
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailTempatMakanPage(tempatMakan: item),
                      ),
                    );
                    _fetchData();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Foto sampul
                      SizedBox(
                        height: 140,
                        width: double.infinity,
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.green[200],
                                  child: const Icon(Icons.storefront, size: 50, color: Colors.white),
                                ),
                              )
                            : Container(
                                color: Colors.green[200],
                                child: const Icon(Icons.storefront, size: 50, color: Colors.white),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: Colors.amber),
                                Text(
                                  ' ${item.rating.toStringAsFixed(1)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.address,
                              style: const TextStyle(color: Colors.grey),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _konfirmasiHapus(item.id, item.name),
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                  label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditTempatMakanPage(tempatMakan: item),
                                      ),
                                    );
                                    if (result == true) _fetchData();
                                  },
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[800],
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
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
        );
      },
    );
  }

  // --------------------------------------------------------
  // TAB 2: Dashboard Statistik
  // --------------------------------------------------------
  Widget _buildDashboardTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 12),
                Text('Gagal memuat: ${snapshot.error}', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchData,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Tidak ada data'));
        }

        final data = snapshot.data!;
        final summary = data['summary'] as Map<String, dynamic>? ?? {};
        final ratingDist = data['rating_distribution'] as Map<String, dynamic>? ?? {};
        final reviewTerbaru = data['review_terbaru'] as List? ?? [];
        final perWarung = data['per_warung'] as List? ?? [];

        return RefreshIndicator(
          onRefresh: () async => _fetchData(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- SUMMARY CARDS ---
              _buildSectionTitle('Ringkasan Bisnis'),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    icon: Icons.storefront,
                    label: 'Total Warung',
                    value: '${summary['total_tempat_makan'] ?? 0}',
                    color: Colors.green[700]!,
                  ),
                  _buildStatCard(
                    icon: Icons.star_rounded,
                    label: 'Rata-rata Rating',
                    value: '${(summary['average_rating'] ?? 0.0).toStringAsFixed(1)} ⭐',
                    color: Colors.amber[700]!,
                  ),
                  _buildStatCard(
                    icon: Icons.rate_review,
                    label: 'Total Review',
                    value: '${summary['total_review'] ?? 0}',
                    color: Colors.blue[700]!,
                  ),
                  _buildStatCard(
                    icon: Icons.favorite,
                    label: 'Pengunjung (Favorit)',
                    value: '${summary['total_favorit'] ?? 0}',
                    color: Colors.pink[600]!,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- DISTRIBUSI RATING ---
              _buildSectionTitle('Distribusi Rating'),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: List.generate(5, (i) {
                      final star = 5 - i;
                      final count = (ratingDist['$star'] ?? 0) as int;
                      final total = (summary['total_review'] ?? 1) as int;
                      final pct = total > 0 ? count / total : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text('$star ⭐', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 10,
                                  backgroundColor: Colors.grey[200],
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('$count', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- STATISTIK PER WARUNG ---
              if (perWarung.isNotEmpty) ...[
                _buildSectionTitle('Performa Per Warung'),
                const SizedBox(height: 8),
                ...perWarung.map((w) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: const Icon(Icons.storefront, color: Colors.green),
                    ),
                    title: Text(
                      w['name'] ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${w['total_review']} review  •  ${w['total_foto']} foto  •  ${w['total_favorit']} favorit',
                    ),
                    trailing: Chip(
                      label: Text(
                        '${(w['rating'] ?? 0.0).toStringAsFixed(1)} ⭐',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      backgroundColor: Colors.amber[100],
                    ),
                  ),
                )),
                const SizedBox(height: 24),
              ],

              // --- REVIEW TERBARU ---
              if (reviewTerbaru.isNotEmpty) ...[
                _buildSectionTitle('Review Terbaru'),
                const SizedBox(height: 8),
                ...reviewTerbaru.map((r) {
                  final user = r['user'] as Map<String, dynamic>? ?? {};
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          (user['name'] ?? 'U').toString().isNotEmpty
                              ? (user['name'] as String)[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            user['name'] ?? 'User',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const Spacer(),
                          Row(
                            children: List.generate(
                              (r['rating'] ?? 0) as int,
                              (_) => const Icon(Icons.star, size: 12, color: Colors.amber),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        r['comment'] ?? '-',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Juragan'),
        backgroundColor: Colors.green[800],
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
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.storefront), text: 'Warung Saya'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Dashboard'),
          ],
        ),
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _tabController,
        builder: (context, _) {
          if (_tabController.index == 0) {
            return FloatingActionButton.extended(
              backgroundColor: Colors.green[800],
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_business),
              label: const Text('Warung Baru'),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTempatMakanPage()),
                );
                if (result == true) _fetchData();
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWarungTab(),
          _buildDashboardTab(),
        ],
      ),
    );
  }
}

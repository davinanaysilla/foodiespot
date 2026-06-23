import 'package:flutter/material.dart';
import '../../models/tempat_makan_model.dart';
import '../../services/tempat_makan_service.dart';
import 'owner_edit_restaurant_screen.dart';

const kBrown = Color(0xFF4A2512);
const kBrownLight = Color(0xFF6B3A1F);
const kCream = Color(0xFFF5F0E8);
const kAccent = Color(0xFFB5651D);

class OwnerRestaurantScreen extends StatefulWidget {
  final TempatMakanModel restaurant;
  final VoidCallback onUpdated;
  final VoidCallback onDeleted;

  const OwnerRestaurantScreen({
    Key? key,
    required this.restaurant,
    required this.onUpdated,
    required this.onDeleted,
  }) : super(key: key);

  @override
  State<OwnerRestaurantScreen> createState() => _OwnerRestaurantScreenState();
}

class _OwnerRestaurantScreenState extends State<OwnerRestaurantScreen> {
  late TempatMakanModel _restaurant;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _restaurant = widget.restaurant;
  }

  @override
  void didUpdateWidget(OwnerRestaurantScreen old) {
    super.didUpdateWidget(old);
    _restaurant = widget.restaurant;
  }

  String _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://10.0.2.2:8000/storage/$url';
  }

  void _editRestaurant() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerEditRestaurantScreen(restaurant: _restaurant),
      ),
    );
    if (result == true) {
      widget.onUpdated();
      Navigator.pop(context, true); // Refresh list
    }
  }

  void _deleteRestaurant() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Warung', style: TextStyle(color: kBrown)),
        content: const Text(
          'Apakah Anda yakin ingin menghapus warung ini? Semua data akan hilang permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isDeleting = true);
              try {
                await TempatMakanService().deleteTempatMakan(_restaurant.id);
                widget.onDeleted();
                if (!mounted) return;
                Navigator.pop(context, true); // Pop detail page back to list with true
              } catch (e) {
                setState(() => _isDeleting = false);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menghapus warung: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = _resolveImageUrl(_restaurant.imageUrl);

    return Scaffold(
      backgroundColor: kCream,
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator(color: kBrown))
          : CustomScrollView(
              slivers: [
                // AppBar with image
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: kBrown,
                  automaticallyImplyLeading: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: const Text(
                    'Data Warung',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: _editRestaurant,
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: resolvedUrl.isNotEmpty
                        ? Image.network(
                            resolvedUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: kBrownLight),
                          )
                        : Container(color: kBrownLight),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _restaurant.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: kBrown,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${_restaurant.rating.toStringAsFixed(1)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(Icons.location_on_outlined, _restaurant.address),
                        const SizedBox(height: 12),
                        Text(
                          _restaurant.description,
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 24),
                        // Foto section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Foto Warung',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kBrown,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _editRestaurant,
                              icon: const Icon(Icons.add_photo_alternate, color: kAccent),
                              label: const Text(
                                'Ubah Foto',
                                style: TextStyle(color: kAccent),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (resolvedUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              resolvedUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 180,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        // Hapus button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _deleteRestaurant,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Hapus Warung'),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
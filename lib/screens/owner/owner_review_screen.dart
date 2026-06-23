import 'package:flutter/material.dart';
import '../../models/tempat_makan_model.dart';
import '../../models/review_model.dart';
import '../../services/review_service.dart';

const kBrown = Color(0xFF4A2512);
const kBrownLight = Color(0xFF6B3A1F);
const kCream = Color(0xFFF5F0E8);
const kAccent = Color(0xFFB5651D);

class OwnerReviewScreen extends StatefulWidget {
  final List<TempatMakanModel> restaurants;
  final List<ReviewModel> reviews;
  final VoidCallback onUpdated;

  const OwnerReviewScreen({
    Key? key,
    required this.restaurants,
    required this.reviews,
    required this.onUpdated,
  }) : super(key: key);

  @override
  State<OwnerReviewScreen> createState() => _OwnerReviewScreenState();
}

class _OwnerReviewScreenState extends State<OwnerReviewScreen> {
  dynamic _selectedRestaurantId = 'all';
  bool _isLoading = false;

  List<ReviewModel> get _filteredReviews {
    if (_selectedRestaurantId == 'all') return widget.reviews;
    return widget.reviews
        .where((r) => r.tempatMakanId == _selectedRestaurantId)
        .toList();
  }

  String _restaurantName(int id) {
    try {
      return widget.restaurants
          .firstWhere((r) => r.id == id)
          .name;
    } catch (_) {
      return 'Warung';
    }
  }

  void _openReplyDialog(ReviewModel review) {
    final ctrl = TextEditingController(text: review.reply ?? '');
    final isEdit = review.reply != null && review.reply!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(isEdit ? 'Edit Balasan' : 'Balas Ulasan',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kBrown)),
              const Spacer(),
              IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close)),
            ]),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: kCream, borderRadius: BorderRadius.circular(10)),
              child: Text('"${review.comment}"',
                  style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                      fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              maxLines: 4,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Tulis balasan Anda...',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kAccent)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrown,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final replyText = ctrl.text.trim();
                  if (replyText.isEmpty) return;
                  Navigator.pop(ctx);
                  setState(() => _isLoading = true);
                  try {
                    if (isEdit) {
                      await ReviewService().updateReply(review.id, replyText);
                    } else {
                      await ReviewService().replyReview(review.id, replyText);
                    }
                    widget.onUpdated();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(isEdit
                            ? 'Balasan berhasil diperbarui'
                            : 'Balasan berhasil dikirim'),
                        backgroundColor: kBrown));
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Gagal mengirim balasan: ${e.toString()}'),
                        backgroundColor: Colors.red));
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
                child: Text(isEdit ? 'Perbarui Balasan' : 'Kirim Balasan',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteReply(ReviewModel review) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Balasan', style: TextStyle(color: kBrown)),
        content: const Text('Apakah Anda yakin ingin menghapus balasan ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await ReviewService().deleteReply(review.id);
                widget.onUpdated();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Balasan berhasil dihapus'),
                        backgroundColor: Colors.red));
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Gagal menghapus balasan: ${e.toString()}'),
                    backgroundColor: Colors.red));
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://10.0.2.2:8000/storage/$url';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredReviews;

    return Scaffold(
      backgroundColor: kCream,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kBrown))
          : Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kBrown, kBrownLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Text(
                    'Monitoring Review',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                // Filter tabs per warung
                if (widget.restaurants.length > 1)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'Semua',
                            selected: _selectedRestaurantId == 'all',
                            onTap: () => setState(() => _selectedRestaurantId = 'all'),
                          ),
                          ...widget.restaurants.map((r) => Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: _FilterChip(
                                  label: r.name,
                                  selected: _selectedRestaurantId == r.id,
                                  onTap: () => setState(() => _selectedRestaurantId = r.id),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),

                // Review list
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.rate_review_outlined,
                                  size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text('Belum ada ulasan untuk warung ini',
                                  style: TextStyle(color: Colors.grey.shade500)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final review = filtered[i];
                            return _ReviewDetailCard(
                              review: review,
                              restaurantName: _restaurantName(review.tempatMakanId),
                              resolvedImageUrl: _resolveImageUrl(review.imageUrl),
                              resolvedUserImageUrl: _resolveImageUrl(review.userPhotoUrl),
                              onReply: () => _openReplyDialog(review),
                              onDeleteReply: () => _deleteReply(review),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? kBrown : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? kBrown : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ReviewDetailCard extends StatelessWidget {
  final ReviewModel review;
  final String restaurantName;
  final String resolvedImageUrl;
  final String resolvedUserImageUrl;
  final VoidCallback onReply;
  final VoidCallback onDeleteReply;

  const _ReviewDetailCard({
    required this.review,
    required this.restaurantName,
    required this.resolvedImageUrl,
    required this.resolvedUserImageUrl,
    required this.onReply,
    required this.onDeleteReply,
  });

  @override
  Widget build(BuildContext context) {
    final hasReply = review.reply != null && review.reply!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warung name & date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kBrown.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  restaurantName,
                  style: const TextStyle(
                      fontSize: 11, color: kBrown, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // User Info Row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: kBrown,
                backgroundImage: resolvedUserImageUrl.isNotEmpty
                    ? NetworkImage(resolvedUserImageUrl)
                    : null,
                child: resolvedUserImageUrl.isEmpty
                    ? Text(
                        review.userName.isNotEmpty
                            ? review.userName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
              // Rating stars
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Comment
          Text(
            review.comment,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),

          // Review image if exists
          if (resolvedImageUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                resolvedImageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],

          // Reply section
          if (hasReply) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kCream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.reply, size: 16, color: kBrown),
                      SizedBox(width: 6),
                      Text(
                        'Balasan Anda',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: kBrown),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    review.reply!,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: onReply,
                        icon: const Icon(Icons.edit, size: 14, color: kAccent),
                        label: const Text('Edit',
                            style: TextStyle(color: kAccent, fontSize: 12)),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: onDeleteReply,
                        icon: const Icon(Icons.delete_outline,
                            size: 14, color: Colors.red),
                        label: const Text('Hapus',
                            style: TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onReply,
                icon: const Icon(Icons.reply, size: 16, color: kBrown),
                label: const Text('Balas Ulasan',
                    style: TextStyle(
                        color: kBrown, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
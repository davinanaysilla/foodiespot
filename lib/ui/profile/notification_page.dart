import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<NotificationModel>> _notificationsFuture;

  static const Color _bgColor = Color(0xFFFCF8F3);
  static const Color _textDark = Color(0xFF2C1A0E);
  static const Color _borderColor = Color(0xFFEAE0D5);
  static const Color _primaryBrown = Color(0xFF8B5E2A);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _notificationsFuture = NotificationService().getNotifications();
    });
  }

  void _markAllAsRead() async {
    try {
      await NotificationService().markAllAsRead();
      _fetchData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  void _markAsRead(int id) async {
    try {
      await NotificationService().markAsRead(id);
      _fetchData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 1) return '${diff.inDays} hari yang lalu';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inHours > 0) return '${diff.inHours} jam yang lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes} menit yang lalu';
    return 'Baru saja';
  }

  Map<String, dynamic> _getIconConfig(String type) {
    switch (type) {
      case 'like':
        return {'icon': Icons.favorite_rounded, 'color': Colors.pink.shade300, 'bg': Colors.pink.shade50};
      case 'review_reply':
        return {'icon': Icons.reply_rounded, 'color': Colors.white, 'bg': _primaryBrown};
      case 'owner_status':
        return {'icon': Icons.storefront_outlined, 'color': Colors.green.shade600, 'bg': Colors.green.shade50};
      case 'system_info':
      default:
        return {'icon': Icons.info_outline_rounded, 'color': Colors.grey.shade600, 'bg': Colors.grey.shade200};
    }
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
        title: const Text('Notifikasi', style: TextStyle(color: _textDark, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: _primaryBrown),
            tooltip: 'Tandai Semua Dibaca',
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _primaryBrown));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Gagal memuat: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text("Belum ada notifikasi.", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final notifications = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _fetchData(),
            color: _primaryBrown,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final isRead = notif.isRead;
                final config = _getIconConfig(notif.type);

                return GestureDetector(
                  onTap: () {
                    if (!isRead) _markAsRead(notif.id);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isRead ? Colors.white : const Color(0xFFFDF7F2), // Slightly orange tint for unread
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isRead ? _borderColor : const Color(0xFFF3E2D0)),
                      boxShadow: isRead ? [] : [
                        BoxShadow(
                          color: _primaryBrown.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: config['bg'] as Color,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(config['icon'] as IconData, color: config['color'] as Color, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                                  color: _textDark,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatTimeAgo(notif.createdAt),
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                        if (!isRead)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


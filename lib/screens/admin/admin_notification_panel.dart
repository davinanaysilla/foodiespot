import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../services/notification_service.dart';
import '../../../models/notification_model.dart';

/// Callback executed when a notification tile is tapped.
/// The caller (AdminHomeScreen) uses [targetTabIndex] to switch to the
/// relevant admin tab (0=Dashboard, 1=Restoran, 2=Pengajuan, 3=Review,
/// 4=Foto, 5=Pengguna).
typedef OnNotificationTap = void Function(int targetTabIndex);

class AdminNotificationPanel extends StatefulWidget {
  final OnNotificationTap onNavigate;

  const AdminNotificationPanel({Key? key, required this.onNavigate})
      : super(key: key);

  @override
  State<AdminNotificationPanel> createState() =>
      _AdminNotificationPanelState();
}

class _AdminNotificationPanelState extends State<AdminNotificationPanel> {
  final _service = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _service.getNotifications();
      if (mounted) setState(() { _notifications = data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllRead() async {
    try {
      await _service.markAllAsRead();
      setState(() {
        _notifications = _notifications
            .map((n) => NotificationModel(
                  id: n.id,
                  userId: n.userId,
                  title: n.title,
                  type: n.type,
                  isRead: true,
                  createdAt: n.createdAt,
                ))
            .toList();
      });
    } catch (_) {}
  }

  Future<void> _onTap(NotificationModel n) async {
    // Mark individual notification as read
    if (!n.isRead) {
      try {
        await _service.markAsRead(n.id);
        setState(() {
          final idx = _notifications.indexWhere((x) => x.id == n.id);
          if (idx != -1) {
            _notifications[idx] = NotificationModel(
              id: n.id,
              userId: n.userId,
              title: n.title,
              type: n.type,
              isRead: true,
              createdAt: n.createdAt,
            );
          }
        });
      } catch (_) {}
    }

    // Navigate to the relevant admin tab then close panel
    final tab = _tabForType(n.type);
    if (!mounted) return;
    Navigator.pop(context); // close bottom sheet
    widget.onNavigate(tab);
  }

  /// Maps notification type to admin tab index.
  int _tabForType(String type) {
    switch (type) {
      case 'owner_status':
        return 2; // Pengajuan
      case 'photo_report':
        return 4; // Foto (laporan foto)
      case 'review_report':
        return 3; // Review
      case 'user_report':
        return 5; // Pengguna
      case 'new_restaurant':
        return 1; // Restoran
      default:
        return 0; // Dashboard
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'owner_status':
        return Icons.assignment_outlined;
      case 'photo_report':
        return Icons.photo_library_outlined;
      case 'review_report':
        return Icons.rate_review_outlined;
      case 'user_report':
        return Icons.people_outline;
      case 'new_restaurant':
        return Icons.store_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'owner_status':
        return AppColors.secondary;
      case 'photo_report':
        return const Color(0xFF6366F1);
      case 'review_report':
        return AppColors.star;
      case 'user_report':
        return AppColors.error;
      case 'new_restaurant':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !n.isRead).length;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_rounded,
                        color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Text('Notifikasi',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    if (unread > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$unread',
                            style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ],
                    const Spacer(),
                    if (unread > 0)
                      TextButton(
                        onPressed: _markAllRead,
                        child: Text('Baca semua',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              // Body
              Expanded(
                child: _isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary))
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.cloud_off,
                                      size: 48, color: AppColors.textLight),
                                  const SizedBox(height: 12),
                                  Text(_error!,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppColors.textSecondary)),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _load,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary),
                                    child: Text('Coba Lagi',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _notifications.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.notifications_none_rounded,
                                        size: 56,
                                        color: AppColors.textLight
                                            .withValues(alpha: 0.5)),
                                    const SizedBox(height: 12),
                                    Text('Belum ada notifikasi',
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: AppColors.textSecondary)),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                controller: scrollCtrl,
                                itemCount: _notifications.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1, indent: 60),
                                itemBuilder: (_, i) {
                                  final n = _notifications[i];
                                  final color = _colorForType(n.type);
                                  return InkWell(
                                    onTap: () => _onTap(n),
                                    child: Container(
                                      color: n.isRead
                                          ? Colors.transparent
                                          : color.withValues(alpha: 0.04),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Icon
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: color
                                                  .withValues(alpha: 0.12),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(_iconForType(n.type),
                                                color: color, size: 20),
                                          ),
                                          const SizedBox(width: 12),
                                          // Content
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(n.title,
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight: n.isRead
                                                            ? FontWeight.w400
                                                            : FontWeight.w600,
                                                        color: AppColors
                                                            .textPrimary)),
                                                const SizedBox(height: 3),
                                                Text(
                                                  _relativeTime(n.createdAt),
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      color: AppColors
                                                          .textLight),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Unread dot
                                          if (!n.isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              margin: const EdgeInsets.only(
                                                  top: 6),
                                              decoration: BoxDecoration(
                                                  color: color,
                                                  shape: BoxShape.circle),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        );
      },
    );
  }
}

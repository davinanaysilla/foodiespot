import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';
import '../auth/login_screen.dart';
import 'admin_dashboard_tab.dart';
import 'admin_restaurants_tab.dart';
import 'admin_applications_tab.dart';
import 'admin_reviews_tab.dart';
import 'admin_photos_tab.dart';
import 'admin_users_tab.dart';
import 'admin_notification_panel.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  static const _navItems = [
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.store_outlined, activeIcon: Icons.store_rounded, label: 'Restoran'),
    _NavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded, label: 'Pengajuan'),
    _NavItem(icon: Icons.rate_review_outlined, activeIcon: Icons.rate_review_rounded, label: 'Review'),
    _NavItem(icon: Icons.photo_library_outlined, activeIcon: Icons.photo_library_rounded, label: 'Foto'),
    _NavItem(icon: Icons.people_outline, activeIcon: Icons.people_rounded, label: 'Pengguna'),
  ];

  final List<Widget> _tabs = const [
    AdminDashboardTab(),
    AdminRestaurantsTab(),
    AdminApplicationsTab(),
    AdminReviewsTab(),
    AdminPhotosTab(),
    AdminUsersTab(),
  ];

  final _authService = AuthService();
  final _notifService = NotificationService();

  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final List<NotificationModel> notifications =
          await _notifService.getNotifications();
      if (!mounted) return;
      setState(() {
        _unreadCount = notifications.where((n) => !n.isRead).length;
      });
    } catch (_) {}
  }

  void _openNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminNotificationPanel(
        onNavigate: (tabIndex) {
          setState(() => _currentIndex = tabIndex);
        },
      ),
    ).then((_) {
      // Refresh unread count after panel is closed
      _loadUnreadCount();
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Konfirmasi Keluar',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari sesi admin?',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _authService.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Keluar', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _navItems[_currentIndex].label,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                Text(
                  'Panel Admin FoodieSpot',
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.white.withValues(alpha: 0.75)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Notification bell with unread badge
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white),
                if (_unreadCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      decoration: const BoxDecoration(
                          color: AppColors.star, shape: BoxShape.circle),
                      child: Text(
                        _unreadCount > 9 ? '9+' : '$_unreadCount',
                        style: GoogleFonts.poppins(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Colors.transparent, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
            onPressed: _openNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: _logout,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textLight,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
          items: _navItems.map((n) => BottomNavigationBarItem(
            icon: Icon(n.icon),
            activeIcon: Icon(n.activeIcon),
            label: n.label,
          )).toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
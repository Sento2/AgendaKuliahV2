import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../viewmodels/notification_viewmodel.dart';
import '../../core/constants/app_theme.dart';
import 'login_screen.dart'; // Sudah di-uncomment

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Palet Warna dari AppTheme
    final Color navyBlue = AppTheme.primary;
    final Color softPink = AppTheme.secondary;
    final Color successColor = Colors.green;
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    // Mengambil data user dan daftar tugas langsung dari ViewModel
    final authViewModel = context.watch<AuthViewModel>();
    final taskViewModel = context.watch<TaskViewModel>();

    final user = authViewModel.currentUser;
    final activeCount = taskViewModel.activeTasks.length;
    final doneCount = taskViewModel.doneTasks.length;
    final themeViewModel = context.watch<ThemeViewModel>();
    final isDarkMode = themeViewModel.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.mainGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x220A192F),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: softPink.withOpacity(0.22),
                    child: Icon(
                      Icons.person_rounded,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.username ?? 'Guest',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pantau progres kuliahmu dari sini',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    value: activeCount,
                    label: 'Tugas Aktif',
                    icon: Icons.schedule_rounded,
                    accent: navyBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    value: doneCount,
                    label: 'Selesai',
                    icon: Icons.task_alt_rounded,
                    accent: successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 6,
              shape: AppTheme.cardShape(radius: 18),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Color(0x1A0A192F).withOpacity(0.08),
                      child: const Icon(
                        Icons.school_rounded,
                        color: AppTheme.primary,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      'Agenda Kuliah',
                      style: TextStyle(
                        color: onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Versi UI yang lebih modern',
                      style: TextStyle(color: onSurfaceVariant, fontSize: 12),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: navyBlue,
                      size: 24,
                    ),
                  ),
                  Divider(height: 0, color: Colors.grey.withOpacity(0.2)),
                  Consumer<NotificationViewModel>(
                    builder: (context, notificationViewModel, child) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Color(0x1AFFC107).withOpacity(0.08),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: AppTheme.secondary,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          'Reminder & Notifikasi',
                          style: TextStyle(
                            color: onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          notificationViewModel.notificationsEnabled
                              ? 'Aktif'
                              : 'Nonaktif',
                          style: TextStyle(
                            color: onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Switch(
                          value: notificationViewModel.notificationsEnabled,
                          onChanged: (value) {
                            notificationViewModel.toggleNotifications(value);
                          },
                          activeColor: AppTheme.secondary,
                        ),
                        onTap: () => _showNotificationSettings(
                          context,
                          notificationViewModel,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 6,
              shape: AppTheme.cardShape(radius: 18),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                secondary: CircleAvatar(
                  backgroundColor: AppTheme.primary.withOpacity(0.08),
                  child: const Icon(
                    Icons.dark_mode_rounded,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Dark Mode',
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Bikin tampilan lebih nyaman saat malam',
                  style: TextStyle(color: onSurfaceVariant, fontSize: 12),
                ),
                value: isDarkMode,
                onChanged: themeViewModel.toggleTheme,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  authViewModel.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required int value,
    required String label,
    required IconData icon,
    required Color accent,
  }) {
    return Card(
      shape: AppTheme.cardShape(radius: 18),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: accent.withOpacity(0.12),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(height: 12),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings(
    BuildContext context,
    NotificationViewModel notificationViewModel,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications_rounded,
                    color: AppTheme.secondary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Pengaturan Notifikasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Aktifkan Notifikasi'),
                subtitle: const Text(
                  'Terima reminder untuk tugas yang mendekati deadline',
                ),
                value: notificationViewModel.notificationsEnabled,
                onChanged: (value) {
                  notificationViewModel.toggleNotifications(value);
                },
                activeColor: AppTheme.secondary,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Waktu Pengingat Sebelum Deadline',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [1, 3, 7].map((days) {
                  return ChoiceChip(
                    label: Text('$days hari'),
                    selected: notificationViewModel.multipleDays.contains(days),
                    onSelected: (selected) {
                      List<int> newDays = List.from(
                        notificationViewModel.multipleDays,
                      );
                      if (selected) {
                        if (!newDays.contains(days)) {
                          newDays.add(days);
                          newDays.sort();
                        }
                      } else {
                        newDays.remove(days);
                      }
                      notificationViewModel.setMultipleDays(newDays);
                    },
                    selectedColor: AppTheme.secondary.withOpacity(0.3),
                    labelStyle: TextStyle(
                      color: notificationViewModel.multipleDays.contains(days)
                          ? AppTheme.secondary
                          : null,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await notificationViewModel.showTestNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifikasi test dikirim! 📲'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Kirim Notifikasi Test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
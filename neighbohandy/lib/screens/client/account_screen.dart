import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/settings_rows.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'apply_as_freelancer_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Log out?',
      body: "Are you sure you want to sign out of this account? You'll need to log in again to book services.",
      confirmLabel: 'Log out',
    );
    if (!confirmed || !context.mounted) return;
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    context.read<AppStateProvider>().clearSession();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('NeighborHandy')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.secondary,
                    child: Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(user?.name ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  Text(user?.email ?? '', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 32),
            SettingsRow(
              icon: Icons.edit_outlined,
              title: 'Edit profile',
              subtitle: 'Name, address, phone number',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
            ),
            SettingsRow(
              icon: Icons.notifications_none,
              title: 'Notifications',
              subtitle: 'Booking updates & freelancer replies',
              trailing: Switch(
                value: user?.notificationsEnabled ?? true,
                onChanged: (v) => context.read<AuthProvider>().setNotificationsEnabled(v),
              ),
            ),
            SettingsRow(
              icon: Icons.dark_mode_outlined,
              title: 'Appearance',
              subtitle: themeProvider.isDark ? 'Dark mode is on' : 'Light mode is on',
              trailing: Switch(
                value: themeProvider.isDark,
                onChanged: (v) => themeProvider.setDark(v),
              ),
            ),
            const Divider(height: 8),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ApplyAsFreelancerScreen()),
                ),
                icon: const Text('🛠️'),
                label: const Text('Apply as Freelancer'),
              ),
            ),
            const SizedBox(height: 6),
            SettingsRow(
              icon: Icons.logout,
              title: 'Log out',
              subtitle: 'Sign out of this account',
              danger: true,
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}

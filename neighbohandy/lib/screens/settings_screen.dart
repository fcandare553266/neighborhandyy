import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'login_screen.dart';

class SettingsDemoScreen extends StatelessWidget {
  const SettingsDemoScreen({super.key});

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const _SignOutDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _settingsTile('Edit profile', () {}),
              _settingsTile('Notifications', () {}),
              _settingsTile('Payment methods', () {}),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _showSignOutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkCard,
                  foregroundColor: textPrimary,
                  side: const BorderSide(color: darkCardBorder),
                ),
                child: const Text('Sign out option'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsTile(String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: darkCardBorder),
      ),
      child: ListTile(
        title: Text(title,
            style: const TextStyle(color: textPrimary, fontSize: 14)),
        trailing:
            const Icon(Icons.chevron_right, color: textMuted, size: 20),
        onTap: onTap,
      ),
    );
  }
}

class _SignOutDialog extends StatelessWidget {
  const _SignOutDialog();

  void _confirmSignOut(BuildContext context) {
    // 1. Clear local session tokens
    // 2. Cancel active push-notification listeners
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: darkCardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '👋',
              style: TextStyle(fontSize: 36),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sign out?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "You'll need to log in again to book services or manage jobs. Any unsaved changes on this screen will be lost.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: darkCardBorder),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _confirmSignOut(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: coralDestructive,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Sign out'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
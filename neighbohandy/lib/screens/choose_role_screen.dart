import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/user_role.dart';
import '../providers/app_state_provider.dart';
import 'admin/admin_console_screen.dart';
import 'role_home_screen.dart';

enum UserRoleChoice { client, freelancer, admin }

class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({super.key});

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  UserRoleChoice _selectedRole = UserRoleChoice.client;
  bool _isLoading = false;

  Future<void> _submitRole() async {
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      String roleString = 'resident';
      UserRole providerRole = UserRole.resident;

      if (_selectedRole == UserRoleChoice.freelancer) {
        roleString = 'freelancer';
        providerRole = UserRole.freelancer;
      } else if (_selectedRole == UserRoleChoice.admin) {
        roleString = 'admin';
        providerRole = UserRole.admin;
      }

      // Save to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'role': roleString,
      }, SetOptions(merge: true));

      if (!mounted) return;

      // Update provider state
      context.read<AppStateProvider>().setRole(providerRole);

      // Direct redirection based on selected role
      if (_selectedRole == UserRoleChoice.admin) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AdminConsoleScreen()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const RoleHomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error setting role: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _buttonText {
    switch (_selectedRole) {
      case UserRoleChoice.freelancer:
        return 'Continue as Freelancer';
      case UserRoleChoice.admin:
        return 'Continue as Admin';
      case UserRoleChoice.client:
        return 'Continue as Client';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'How will you use the app?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'You can change or switch roles later',
                style: TextStyle(color: textMuted, fontSize: 13),
              ),
              const SizedBox(height: 28),

              // 1. Client Card
              _RoleCard(
                icon: Icons.receipt_long_outlined,
                title: 'I need a service',
                subtitle: 'Book local freelancers for home & personal services',
                isSelected: _selectedRole == UserRoleChoice.client,
                onTap: () =>
                    setState(() => _selectedRole = UserRoleChoice.client),
              ),
              const SizedBox(height: 16),

              // 2. Freelancer Card
              _RoleCard(
                icon: Icons.build_outlined,
                title: 'I offer a service',
                subtitle: 'List your services and receive job requests nearby',
                isSelected: _selectedRole == UserRoleChoice.freelancer,
                onTap: () =>
                    setState(() => _selectedRole = UserRoleChoice.freelancer),
              ),
              const SizedBox(height: 16),

              // 3. Admin Card
              _RoleCard(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Admin Console',
                subtitle: 'Access administrative & system monitoring tools',
                isSelected: _selectedRole == UserRoleChoice.admin,
                onTap: () =>
                    setState(() => _selectedRole = UserRoleChoice.admin),
              ),

              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightAccent,
                  foregroundColor: darkBackground,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _submitRole,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: darkBackground,
                        ),
                      )
                    : Text(
                        _buttonText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF282538) : darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B93FF) : darkCardBorder,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: textPrimary, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF8B93FF) : textMuted,
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFF8B93FF)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.circle, size: 8, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

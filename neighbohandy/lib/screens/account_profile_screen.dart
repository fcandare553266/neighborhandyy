import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../models/user_role.dart';
import '../providers/app_state_provider.dart';
import 'setup_freelancer_profile_screen.dart';

class AccountProfileScreen extends StatelessWidget {
  const AccountProfileScreen({super.key});

  String _formatDisplayName(User? user, String providerName) {
    if (providerName.isNotEmpty) return providerName;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    
    final emailName = user?.email?.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ');
    if (emailName == null || emailName.isEmpty) return 'User Account';

    return emailName
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part.length > 1
            ? part[0].toUpperCase() + part.substring(1).toLowerCase()
            : part.toUpperCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final appState = context.watch<AppStateProvider>();
    
    final displayName = _formatDisplayName(user, appState.userName);
    final userEmail = user?.email ?? 'No email provided';
    final isFreelancer = appState.currentRole == UserRole.freelancer;

    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Account',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // User Info Card
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: darkBackground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: const TextStyle(
                        color: textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Account Role Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: darkCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: darkCardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_outlined, color: lightAccent),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Account role',
                          style: TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isFreelancer ? 'Freelancer' : 'Client',
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Apply / Switch Freelancer Mode
              if (!isFreelancer)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SetupFreelancerProfileScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: darkCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: darkCardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.work_outline, color: textPrimary),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Apply as a Freelancer',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Offer your services to nearby neighbors',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: textMuted),
                      ],
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
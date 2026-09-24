import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/user_role.dart';
import '../providers/app_state_provider.dart';
import 'admin/admin_console_screen.dart';
import 'choose_role_screen.dart';
import 'login_screen.dart';
import 'role_home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: darkBackground,
            body: Center(child: CircularProgressIndicator(color: lightAccent)),
          );
        }

        final user = authSnapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        // Listen live to user's Firestore document
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: darkBackground,
                body: Center(child: CircularProgressIndicator(color: lightAccent)),
              );
            }

            final userData = userSnapshot.data?.data();
            final String rawRole = (userData?['role'] ??
                    userData?['accountType'] ??
                    userData?['userRole'] ??
                    '')
                .toString()
                .trim()
                .toLowerCase();

            // 1. Direct Admin identification
            if (rawRole == 'admin') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.read<AppStateProvider>().setRole(UserRole.admin);
                }
              });
              return const AdminConsoleScreen();
            }

            // 2. Unassigned role -> Go to selection screen
            if (rawRole.isEmpty) {
              return const ChooseRoleScreen();
            }

            // 3. Client or Freelancer roles
            final UserRole assignedRole = rawRole == 'freelancer'
                ? UserRole.freelancer
                : UserRole.resident;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.read<AppStateProvider>().setRole(assignedRole);
              }
            });

            return const RoleHomeScreen();
          },
        );
      },
    );
  }
}
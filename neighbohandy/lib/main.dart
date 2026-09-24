import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'firebase_options.dart';
import 'providers/app_state_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/freelancer_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/admin/admin_console_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/client/client_shell.dart';
import 'screens/freelancer/freelancer_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const NeighborHandyApp());
}

class NeighborHandyApp extends StatelessWidget {
  const NeighborHandyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => FreelancerProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'NeighborHandy',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

/// Single source of truth - uses AuthProvider only
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading && auth.currentUser == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (auth.errorMessage != null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(auth.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<AuthProvider>().logout(),
                      child: const Text('Back to Login'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!auth.isLoggedIn || auth.currentUser == null) {
          return const LoginScreen();
        }

        final role = auth.currentUser!.role.toLowerCase();

        if (role == 'admin') {
          return const AdminConsoleScreen();
        } else if (role == 'freelancer') {
          return const FreelancerShell();
        } else {
          // resident, client, or anything else = client
          return const ClientShell();
        }
      },
    );
  }
}
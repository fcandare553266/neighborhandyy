import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_role.dart';
import '../providers/app_state_provider.dart';
import 'admin/admin_console_screen.dart';
import 'client/book_service_screen.dart';
import 'freelancer/freelancer_requests_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class RoleHomeScreen extends StatefulWidget {
  const RoleHomeScreen({super.key});

  @override
  State<RoleHomeScreen> createState() => _RoleHomeScreenState();
}

class _RoleHomeScreenState extends State<RoleHomeScreen> {
  int _selectedIndex = 0;
  UserRole? _lastRole;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final role = appState.currentRole;

    // FIX: Reset tab index when role changes
    if (_lastRole!= null && _lastRole!= role) {
      _selectedIndex = 0;
    }
    _lastRole = role;

    final user = FirebaseAuth.instance.currentUser;
    final displayName = appState.userName.isNotEmpty
       ? appState.userName
        : _displayName(user);
    final isClient = role == UserRole.resident;

    final destinations = isClient
       ? const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Book',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Account',
            ),
          ]
        : role == UserRole.admin
           ? const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Oversight',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ]
            : const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Requests',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ];

    if (_selectedIndex >= destinations.length) {
      _selectedIndex = 0;
    }

    final children = isClient
       ? [
            HomeScreen(displayName: displayName),
            const BookServiceScreen(),
            const ProfileScreen(),
          ]
        : role == UserRole.admin
           ? [
                const AdminConsoleScreen(),
                const ProfileScreen(),
              ]
            : [
                FreelancerRequestsScreen(
                  freelancerId: FirebaseAuth.instance.currentUser?.uid?? '',
                ),
                const ProfileScreen(),
              ];

    return Scaffold(
      key: ValueKey(role), // FIX: Force rebuild entire scaffold when role switches
      appBar: AppBar(
        title: Text(
          isClient? 'NeighborHandy' : 'NeighborHandy • ${_roleLabel(role)}',
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: children,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: destinations,
      ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.freelancer:
        return 'Freelancer';
      case UserRole.resident:
        return 'Client';
    }
  }

  String _displayName(User? user) {
    final name = user?.displayName?.trim();
    if (name!= null && name.isNotEmpty) return name;
    final emailName = user?.email
       ?.split('@')
       .first
       .replaceAll(RegExp(r'[._-]+'), ' ');
    if (emailName == null || emailName.trim().isEmpty) return 'Neighbor';
    return emailName
       .split(' ')
       .where((part) => part.isNotEmpty)
       .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
       .join(' ');
  }
}
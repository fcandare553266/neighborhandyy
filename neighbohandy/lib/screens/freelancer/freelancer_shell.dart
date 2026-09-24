import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'job_requests_screen.dart';
import 'booked_dates_screen.dart';
import 'profile_screen.dart';

/// Bottom nav shell for the freelancer role: Requests / Booked / Profile.
class FreelancerShell extends StatefulWidget {
  const FreelancerShell({super.key});
  @override
  State<FreelancerShell> createState() => _FreelancerShellState();
}

class _FreelancerShellState extends State<FreelancerShell> {
  int _index = 0;

  final _screens = const [JobRequestsScreen(), BookedDatesScreen(), FreelancerProfileAccountScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: AppColors.primary,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view, color: Colors.white), label: 'Requests'),
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today, color: Colors.white), label: 'Booked'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: Colors.white), label: 'Profile'),
        ],
      ),
    );
  }
}

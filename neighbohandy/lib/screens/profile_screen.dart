import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';
import '../models/user_role.dart';
import '../providers/app_state_provider.dart';
import 'setup_freelancer_profile_screen.dart';
import 'login_screen.dart';

const _freelancerServices = [
  (
    name: 'Plumber',
    description: 'Repair water lines, fix leaky faucets, clear clogged pipes, and install water heaters.',
  ),
  (
    name: 'Electrician',
    description: 'Wire fixtures, upgrade breaker panels, diagnose outages, and install smart switches.',
  ),
  (
    name: 'HVAC Technician',
    description: 'Install and service air conditioners, fix heating systems, and clean air ducts.',
  ),
  (
    name: 'Appliance Repair Technician',
    description: 'Troubleshoot and repair refrigerators, washing machines, dishwashers, and ovens.',
  ),
  (
    name: 'Locksmith',
    description: 'Handle lockouts, rekey doors, install smart locks, and duplicate keys.',
  ),
  (
    name: 'Handyman / Handyperson',
    description: 'Handle odd jobs, assemble furniture, hang TVs, and perform minor maintenance.',
  ),
  (
    name: 'Carpenter',
    description: 'Repair cabinets, hang doors, build shelving, and install trim or baseboards.',
  ),
  (
    name: 'Painter',
    description: 'Prepare and paint interior walls, ceilings, doors, and exterior siding.',
  ),
  (
    name: 'Tile Setter & Mason',
    description:
        'Lay tile, regrout showers, repair concrete, and set brickwork.',
  ),
  (
    name: 'Roofer',
    description: 'Patch roof leaks, replace shingles, clean gutters, and install flashing.',
  ),
  (
    name: 'Drywall & Plaster Specialist',
    description:
        'Patch holes, repair ceilings, hang drywall, and finish seams.',
  ),
  (
    name: 'Flooring Installer',
    description: 'Install hardwood, laminate, vinyl plank, or carpet and refinish wood floors.',
  ),
  (
    name: 'Waterproofing Specialist',
    description: 'Seal basements, balconies, and foundations to prevent water and mold damage.',
  ),
  (
    name: 'Gardener & Landscaper',
    description: 'Mow lawns, trim hedges, plant, install sod, and clean up yards seasonally.',
  ),
  (
    name: 'Exterminator / Pest Control',
    description:
        'Inspect for and treat termites, ants, rodents, bedbugs, and wasps.',
  ),
  (
    name: 'Window Washer',
    description: 'Clean window panes, screens, and tracks, including hard-to-reach glass.',
  ),
];

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().streamUserApplication(user.uid),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final application = docs.isEmpty ? null : docs.first.data() as Map<String, dynamic>;
        final status = application?['status'] as String?;
        return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 12),
          Text(
            user.displayName?.isNotEmpty == true
                ? user.displayName!
                : 'User Account',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            user.email ?? '',
            style: TextStyle(color: Colors.grey),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: const Text('Account role'),
            subtitle: Text(_roleLabel(appState.currentRole)),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log out'),
            subtitle: const Text('Sign out of this account'),
            onTap: () => _logout(context),
          ),
          if (appState.currentRole == UserRole.resident) ...[
            if (status == null || status == 'rejected')
              ListTile(
                leading: const Icon(Icons.work, color: Colors.blue),
                title: const Text('Apply as a Freelancer'),
                subtitle: const Text('Offer your services to nearby neighbors'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showApplyDialog(context, appState),
              )
            else if (status == 'pending')
              const ListTile(
                leading: Icon(Icons.hourglass_top, color: Colors.orange),
                title: Text('Freelancer Application Pending'),
                subtitle: Text(
                  'Admin is currently reviewing your profile application.',
                ),
              )
            else if (status == 'approved')
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Application Approved!'),
                subtitle: const Text('Tap here to set up your services & logo'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SetupFreelancerProfileScreen(),
                    ),
                  );
                },
              ),
          ],
        ],
      ),
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
  // FIXED: Clear provider FIRST, then sign out
  context.read<AppStateProvider>().clearSession();
  await FirebaseAuth.instance.signOut();
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.freelancer:
        return 'Freelancer';
      case UserRole.resident:
        return 'Client';
    }
  }

  void _showApplyDialog(BuildContext context, AppStateProvider appState) {
    ({String name, String description})? selectedService;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apply as Freelancer'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            final selected = selectedService;
            return SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Choose a service',
                      prefixIcon: Icon(Icons.handyman_outlined),
                    ),
                    items: _freelancerServices
                        .map(
                          (service) => DropdownMenuItem(
                            value: service.name,
                            child: Text(service.name),
                          ),
                        )
                        .toList(),
                    onChanged: (name) {
                      final service = _freelancerServices.firstWhere(
                        (item) => item.name == name,
                      );
                      setDialogState(() => selectedService = service);
                    },
                  ),
                  if (selected != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      selected.description,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedService != null) {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;
                try {
                  await FirestoreService().submitFreelancerApplication(
                    userId: user.uid,
                    userName: user.displayName ?? 'Neighbor',
                    userEmail: user.email ?? '',
                    serviceName: selectedService!.name,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Application submitted to Admin!'),
                    ),
                  );
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not submit application: $error')),
                  );
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

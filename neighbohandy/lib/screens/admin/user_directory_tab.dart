import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class UserDirectoryTab extends StatefulWidget {
  const UserDirectoryTab({super.key});

  @override
  State<UserDirectoryTab> createState() => _UserDirectoryTabState();
}

class _UserDirectoryTabState extends State<UserDirectoryTab> {
  // Toggle between 'clients' and 'freelancers'
  String _selectedType = 'clients';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle Buttons Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Clients')),
                  selected: _selectedType == 'clients',
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = 'clients');
                  },
                  selectedColor: softCream,
                  backgroundColor: darkCard,
                  labelStyle: TextStyle(
                    color: _selectedType == 'clients' ? darkBackground : textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Freelancers')),
                  selected: _selectedType == 'freelancers',
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = 'freelancers');
                  },
                  selectedColor: softCream,
                  backgroundColor: darkCard,
                  labelStyle: TextStyle(
                    color: _selectedType == 'freelancers' ? darkBackground : textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Live User Directory Stream
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: lightAccent),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              // Filter docs dynamically on client side to handle role variations
              final filteredUsers = docs.where((doc) {
                final data = doc.data();
                final role = (data['role'] ?? '').toString().trim().toLowerCase();

                if (_selectedType == 'clients') {
                  // Matches 'client', 'resident', or unassigned regular users
                  return role == 'client' || role == 'resident' || role.isEmpty;
                } else {
                  // Matches 'freelancer'
                  return role == 'freelancer';
                }
              }).toList();

              if (filteredUsers.isEmpty) {
                return const Center(
                  child: Text(
                    'No matching users found.',
                    style: TextStyle(color: textMuted),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final userData = filteredUsers[index].data();
                  final name = userData['name'] ?? userData['fullName'] ?? 'Unnamed User';
                  final email = userData['email'] ?? 'No email provided';

                  return Card(
                    color: darkCard,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: darkCardBorder),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: lightAccent.withValues(alpha: 0.1),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(color: lightAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        email,
                        style: const TextStyle(color: textMuted, fontSize: 12),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: darkBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: darkCardBorder),
                        ),
                        child: Text(
                          (userData['role'] ?? 'Client').toString().toUpperCase(),
                          style: const TextStyle(color: lightAccent, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
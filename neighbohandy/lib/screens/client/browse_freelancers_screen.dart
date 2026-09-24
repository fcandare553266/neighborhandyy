import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/app_state_provider.dart';
import 'book_service_screen.dart';
import 'set_address_screen.dart';

class BrowseFreelancersScreen extends StatefulWidget {
  const BrowseFreelancersScreen({super.key});

  @override
  State<BrowseFreelancersScreen> createState() =>
      _BrowseFreelancersScreenState();
}

class _BrowseFreelancersScreenState extends State<BrowseFreelancersScreen> {
  String _selectedCategory = 'All services';

  @override
  Widget build(BuildContext context) {
    final currentAddress = context.watch<AppStateProvider>().address;

    return Scaffold(
      appBar: AppBar(title: const Text('Browse Services')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Freelancers near you',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Location Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentAddress.isEmpty
                          ? 'Set your address'
                          : currentAddress,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SetAddressScreen(),
                        ),
                      );
                    },
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    [
                      'All services',
                      'Cleaning',
                      'Repair',
                      'Plumbing',
                      'Electrical',
                    ].map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(cat),
                          onSelected: (selected) {
                            setState(() => _selectedCategory = cat);
                          },
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Freelancers List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _selectedCategory == 'All services'
                    ? FirebaseFirestore.instance
                          .collection('freelancers')
                          .snapshots()
                    : FirebaseFirestore.instance
                          .collection('freelancers')
                          .where('service', isEqualTo: _selectedCategory)
                          .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading freelancers: ${snapshot.error}',
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('No freelancers available in this category.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final freelancer = {...data, 'id': docs[index].id};
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(data['name'] ?? 'Freelancer'),
                          subtitle: Text(data['service'] ?? 'General Services'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookServiceScreen(
                                    freelancer: freelancer,
                                    address: currentAddress,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Book'),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

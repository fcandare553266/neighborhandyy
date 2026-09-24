import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import 'client/browse_freelancers_screen.dart';

class HomeScreen extends StatelessWidget {
  final String? displayName;

  const HomeScreen({super.key, this.displayName});

  void _showAddressDialog(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context, listen: false);
    final controller = TextEditingController(text: provider.address);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Address'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Address',
              hintText: 'Enter your location',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final input = controller.text.trim();
                if (input.isNotEmpty) {
                  provider.setAddress(input);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentAddress = context.watch<AppStateProvider>().address;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (displayName != null && displayName!.isNotEmpty) ...[
            Text(
              'Hello, $displayName!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
          ],

          // Address Card
          const Text(
            'Your saved address',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.location_on, size: 28),
              title: const Text(
                'DEFAULT ADDRESS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              subtitle: Text(
                currentAddress.isEmpty ? 'Not set yet' : currentAddress,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: TextButton(
                onPressed: () => _showAddressDialog(context),
                child: const Text('Set address'),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Categories Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BrowseFreelancersScreen(),
                    ),
                  );
                },
                child: const Text('See all'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
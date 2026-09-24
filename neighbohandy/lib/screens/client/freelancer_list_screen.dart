import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/freelancer_provider.dart';
import '../../widgets/freelancer_card.dart';
import 'freelancer_profile_screen.dart';

/// Freelancers under [category] whose city matches the client's saved city.
/// The filtering itself happens in FreelancerProvider / FirestoreService —
/// this screen only renders whatever comes back.
class FreelancerListScreen extends StatefulWidget {
  final CategoryModel category;
  const FreelancerListScreen({super.key, required this.category});

  @override
  State<FreelancerListScreen> createState() => _FreelancerListScreenState();
}

class _FreelancerListScreenState extends State<FreelancerListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final city = context.read<AuthProvider>().currentUser?.city ?? '';
      context.read<FreelancerProvider>().loadFreelancers(
            category: widget.category.id,
            clientCity: city,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final city = context.watch<AuthProvider>().currentUser?.city ?? 'your city';
    final provider = context.watch<FreelancerProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Text('📍 Showing results in $city',
                        style: const TextStyle(fontSize: 11.5)),
                  ),
                ),
                const SizedBox(height: 12),
                if (provider.matchedFreelancers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'No ${widget.category.name.toLowerCase()} freelancers in $city yet.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  )
                else
                  ...provider.matchedFreelancers.map(
                    (f) => FreelancerCard(
                      freelancer: f,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => FreelancerProfileScreen(freelancer: f)),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

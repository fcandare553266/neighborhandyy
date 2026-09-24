import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/freelancer_provider.dart';
import '../../widgets/category_tile.dart';
import 'categories_screen.dart';
import 'edit_profile_screen.dart';
import 'freelancer_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FreelancerProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final freelancerProvider = context.watch<FreelancerProvider>();
    final user = auth.currentUser;
    final previewCategories = freelancerProvider.categories.take(4).toList();
    final savedAddress = user?.address.trim() ?? '';
    final savedCity = user?.city.trim() ?? '';
    final defaultAddress = savedAddress.isNotEmpty
        ? savedAddress
        : savedCity.isNotEmpty
        ? savedCity
        : 'Not set';

    return Scaffold(
      appBar: AppBar(title: const Text('NeighborHandy')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Hello, ${user?.name.split(' ').first ?? 'there'}!',
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            const Text(
              'Your saved address',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.location_on_outlined),
                ),
                title: Text(
                  'DEFAULT ADDRESS',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                subtitle: Text(
                  defaultAddress,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ),
                  child: const Text('Set address'),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 18, bottom: 10),
                  child: Text(
                    'Categories',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                  ),
                  child: const Text('See all'),
                ),
              ],
            ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.3,
              children: previewCategories
                  .map(
                    (c) => CategoryTile(
                      category: c,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FreelancerListScreen(category: c),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

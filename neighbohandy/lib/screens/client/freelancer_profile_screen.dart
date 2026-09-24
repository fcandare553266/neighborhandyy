import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/freelancer_model.dart';
import '../../widgets/primary_button.dart';
import 'booking_form_screen.dart';

class FreelancerProfileScreen extends StatelessWidget {
  final FreelancerModel freelancer;
  const FreelancerProfileScreen({super.key, required this.freelancer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.secondary,
                    backgroundImage:
                        freelancer.photoUrl != null ? NetworkImage(freelancer.photoUrl!) : null,
                    child: freelancer.photoUrl == null
                        ? const Icon(Icons.person, color: Colors.white, size: 30)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(freelancer.companyName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  Text('${freelancer.category} · ${freelancer.city}',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text('★ ${freelancer.rating.toStringAsFixed(1)} (${freelancer.jobsCompleted} jobs)'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Column(
                  children: [
                    _InfoRow(label: 'Rate', value: '₱${freelancer.ratePerHour.toStringAsFixed(0)} / hr'),
                    _InfoRow(label: 'Availability', value: freelancer.availability),
                    _InfoRow(label: 'Service area', value: freelancer.city),
                    _InfoRow(label: 'Jobs completed', value: '${freelancer.jobsCompleted}'),
                  ],
                ),
              ),
            ),
            if (freelancer.about.isNotEmpty) ...[
              const SizedBox(height: 18),
              const Text('About', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 6),
              Text(freelancer.about, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 22),
            PrimaryButton(
              label: 'Book this freelancer',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BookingFormScreen(freelancer: freelancer)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

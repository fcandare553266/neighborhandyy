import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/freelancer_model.dart';

class FreelancerCard extends StatelessWidget {
  final FreelancerModel freelancer;
  final VoidCallback onTap;

  const FreelancerCard({super.key, required this.freelancer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: AppColors.secondary,
                backgroundImage: freelancer.photoUrl != null
                    ? NetworkImage(freelancer.photoUrl!)
                    : null,
                child: freelancer.photoUrl == null
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(freelancer.companyName,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('★ ${freelancer.rating.toStringAsFixed(1)} · ₱${freelancer.ratePerHour.toStringAsFixed(0)}/hr',
                        style: theme.textTheme.bodySmall),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.confirmedBgDark : AppColors.confirmedBgLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('📍 ${freelancer.city} — matches you',
                          style: TextStyle(
                              fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.confirmed)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

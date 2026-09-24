import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const CategoryTile({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(category.name,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('${category.nearbyCount} nearby', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

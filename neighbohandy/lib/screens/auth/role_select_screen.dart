import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

/// Shown right after sign-up. Returns 'client' or 'freelancer' via Navigator.pop.
class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});
  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  String _selected = 'client';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose your role')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('How will you use the app?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('You can add the other role later from your profile',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 20),
              _RoleCard(
                icon: '🧾',
                title: 'I need a service',
                subtitle: 'Book local freelancers for home & personal services',
                selected: _selected == 'client',
                onTap: () => setState(() => _selected = 'client'),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                icon: '🛠️',
                title: 'I offer a service',
                subtitle: 'List your services and receive job requests nearby',
                selected: _selected == 'freelancer',
                onTap: () => setState(() => _selected = 'freelancer'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(_selected),
                child: Text('Continue as ${_selected == 'client' ? 'Client' : 'Freelancer'}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String icon, title, subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secondary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          border: Border.all(
            color: selected ? AppColors.secondary : theme.colorScheme.outline,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.secondary : theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

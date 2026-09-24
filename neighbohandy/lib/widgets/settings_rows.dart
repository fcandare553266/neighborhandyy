import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// A tappable settings row with a leading icon, title, subtitle, and either
/// a chevron (default) or a trailing widget you pass in (a Switch, etc).
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleColor = danger ? AppColors.danger : theme.colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: titleColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: titleColor)),
                  const SizedBox(height: 1),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            trailing ?? Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}

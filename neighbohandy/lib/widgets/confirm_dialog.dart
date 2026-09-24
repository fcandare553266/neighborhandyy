import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Generic blocking confirmation — used for "Log out?" on both the client
/// and freelancer profile screens (and reusable for admin suspend, etc).
class ConfirmDialog extends StatelessWidget {
  final String icon;
  final String title;
  final String body;
  final String confirmLabel;
  final bool destructive;

  const ConfirmDialog({
    super.key,
    this.icon = '👋',
    required this.title,
    required this.body,
    this.confirmLabel = 'Confirm',
    this.destructive = true,
  });

  static Future<bool> show(
    BuildContext context, {
    String icon = '👋',
    required String title,
    required String body,
    String confirmLabel = 'Confirm',
    bool destructive = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        icon: icon,
        title: title,
        body: body,
        confirmLabel: confirmLabel,
        destructive: destructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
      content: Text(body, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: destructive ? AppColors.danger : AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ),
      ],
    );
  }
}

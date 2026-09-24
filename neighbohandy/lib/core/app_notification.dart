import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

Future<void> showAppNotification(BuildContext context, String message) async {
  await SystemSound.play(SystemSoundType.alert);

  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surfaceDark,
      icon: const Icon(Icons.notifications_active, color: AppColors.primaryDark),
      title: const Text(
        'New notification',
        style: TextStyle(color: AppColors.textDark),
      ),
      content: Text(message, style: const TextStyle(color: AppColors.textSoftDark)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('OK', style: TextStyle(color: AppColors.primaryDark)),
        ),
      ],
    ),
  );
}

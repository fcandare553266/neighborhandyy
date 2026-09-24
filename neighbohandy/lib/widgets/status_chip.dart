import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/booking_model.dart';

class StatusChip extends StatelessWidget {
  final BookingStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    late Color fg;
    late Color bg;
    late String label;

    switch (status) {
      case BookingStatus.pending:
        fg = AppColors.pending;
        bg = isDark ? AppColors.pendingBgDark : AppColors.pendingBgLight;
        label = 'PENDING';
        break;
      case BookingStatus.accepted:
        fg = AppColors.confirmed;
        bg = isDark ? AppColors.confirmedBgDark : AppColors.confirmedBgLight;
        label = 'CONFIRMED';
        break;
      case BookingStatus.completed:
        fg = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
        bg = Theme.of(context).colorScheme.surfaceContainerHighest;
        label = 'COMPLETED';
        break;
      case BookingStatus.declined:
      case BookingStatus.cancelled:
        fg = AppColors.danger;
        bg = isDark ? AppColors.dangerBgDark : AppColors.dangerBgLight;
        label = status == BookingStatus.declined ? 'DECLINED' : 'CANCELLED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 9.5, fontWeight: FontWeight.w800),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../models/booking_model.dart';
import 'status_chip.dart';

/// Used on the freelancer's Job Requests screen — shows the request and
/// (for pending ones) Accept / Decline right on the card.
class BookingRequestCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const BookingRequestCard({
    super.key,
    required this.booking,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.category,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('Client: ${booking.clientName}', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                StatusChip(status: booking.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '📍 ${booking.clientAddress}\n🕑 ${DateFormat.yMMMd().format(booking.date)}, ${booking.time}',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
            ),
            if (booking.status == BookingStatus.pending && onAccept != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                      ),
                      onPressed: onDecline,
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.confirmed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                      ),
                      onPressed: onAccept,
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

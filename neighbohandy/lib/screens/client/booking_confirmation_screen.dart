import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final String freelancerName;
  final String serviceType;
  final String dateStr;
  final String timeStr;
  final String address;
  final int totalPrice;
  final String? bookingId;

  const BookingConfirmationScreen({
    super.key,
    required this.freelancerName,
    required this.serviceType,
    required this.dateStr,
    required this.timeStr,
    required this.address,
    required this.totalPrice,
    this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Booking requested',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: darkCardBorder),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E3D38),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.check_box_outlined, color: Color(0xFF62D2A2), size: 36),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Request sent to $freelancerName',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "You'll get a push notification once she responds",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: darkCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: darkCardBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$serviceType · $dateStr, $timeStr',
                            style: const TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$address · ₱$totalPrice',
                            style: const TextStyle(color: textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: darkCardBorder,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Pending',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: darkCard.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: darkCardBorder, style: BorderStyle.solid),
                ),
                child: Row(
                  children: [
                    const Text('🔔', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '"$freelancerName accepted your booking for $dateStr, $timeStr" — tap to view details',
                        style: const TextStyle(color: textMuted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('View my bookings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
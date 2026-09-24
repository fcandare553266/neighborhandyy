import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class JobDetailScreen extends StatelessWidget {
  final String bookingId;
  final Map<String, dynamic> bookingData;

  const JobDetailScreen({
    super.key,
    required this.bookingId,
    required this.bookingData,
  });

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request marked as $newStatus')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating job status: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientName = bookingData['clientName'] ?? 'Client';
    final serviceType = bookingData['serviceType'] ?? 'Service';
    final estHours = bookingData['estimatedHours'] ?? 3;
    final address = bookingData['address'] ?? 'Address not specified';
    final bookingDate = bookingData['bookingDate'] ?? '';
    final bookingTime = bookingData['bookingTime'] ?? '';
    final totalPrice = bookingData['totalPrice'] ?? 0;
    final platformFee = bookingData['platformFee'] ?? 50;
    final payout = (totalPrice is num ? totalPrice : 0) - (platformFee is num ? platformFee : 0);

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: Text('Request from $clientName', style: const TextStyle(color: textPrimary, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Client Summary Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: darkCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: darkCardBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: darkCardBorder,
                      child: Text(
                        clientName.isNotEmpty ? clientName[0].toUpperCase() : 'C',
                        style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(clientName, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text('★ ${bookingData['clientRating'] ?? 4.8} as a client · ${bookingData['clientPastBookings'] ?? 3} past bookings',
                            style: const TextStyle(color: textMuted, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Detail Block 1: Service Requested
              const Text('Service requested', style: TextStyle(color: textMuted, fontSize: 12)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: darkCardBorder),
                ),
                child: Text('$serviceType · $estHours hrs', style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              // Detail Block 2: Client's Saved Address
              const Text("Client's saved address", style: TextStyle(color: textMuted, fontSize: 12)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: darkCardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.home_outlined, size: 16, color: textMuted),
                        const SizedBox(width: 8),
                        Text(address, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Detail Block 3: Requested Time
              const Text('Requested time', style: TextStyle(color: textMuted, fontSize: 12)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: darkCardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: textMuted),
                    const SizedBox(width: 8),
                    Text('$bookingDate · ', style: const TextStyle(color: textPrimary)),
                    const Icon(Icons.access_time_outlined, size: 16, color: textMuted),
                    const SizedBox(width: 6),
                    Text(bookingTime, style: const TextStyle(color: textPrimary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Detail Block 4: Payout
              const Text('Payout for this job', style: TextStyle(color: textMuted, fontSize: 12)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: darkCardBorder),
                ),
                child: Text('₱$payout (after platform fee)', style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: darkCardBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => _updateStatus(context, 'Declined'),
                      child: const Text('Decline', style: TextStyle(color: textPrimary)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF62D2A2),
                        foregroundColor: darkBackground,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => _updateStatus(context, 'Accepted'),
                      child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
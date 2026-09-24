import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class AcceptedBookingsScreen extends StatelessWidget {
  final String freelancerId;

  const AcceptedBookingsScreen({super.key, required this.freelancerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: const Text('Booked Schedule'),
        backgroundColor: darkBackground,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('freelancerId', isEqualTo: freelancerId)
            .where('status', isEqualTo: 'Accepted')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No accepted bookings found.',
                style: TextStyle(color: textMuted),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: darkCardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['clientName'] ?? 'Client',
                          style: const TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Accepted',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Booked Date: ${data['bookingDate'] ?? 'N/A'}',
                      style: const TextStyle(
                        color: lightAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Time: ${data['bookingTime'] ?? 'N/A'}',
                      style: const TextStyle(color: textMuted),
                    ),
                    Text(
                      'Address: ${data['address'] ?? 'N/A'}',
                      style: const TextStyle(color: textMuted),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
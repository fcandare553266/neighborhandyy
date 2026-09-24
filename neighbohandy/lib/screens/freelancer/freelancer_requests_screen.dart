import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class FreelancerRequestsScreen extends StatelessWidget {
  final String freelancerId;

  const FreelancerRequestsScreen({super.key, required this.freelancerId});

  Future<void> _updateBookingStatus(
    BuildContext context,
    String docId,
    String status,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(docId).update(
        {'status': status},
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking $status successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(freelancerId)
          .get(),
      builder: (context, userSnapshot) {
        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
        final serviceRole = userData?['serviceRole'] ?? 'Freelancer';

        return Scaffold(
          backgroundColor: darkBackground,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: lightAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Role: $serviceRole',
                      style: const TextStyle(
                        color: lightAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pending Booking Requests',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('bookings')
                          .where('freelancerId', isEqualTo: freelancerId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final docs = (snapshot.data?.docs ?? []).where((doc) {
                          final status = (doc.data()['status'] ?? '')
                              .toString()
                              .toLowerCase();
                          return status == 'pending';
                        }).toList();
                        if (docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'No pending requests.',
                              style: TextStyle(color: textMuted),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data();
                            final clientName = data['clientName'] ?? 'Client';
                            final bookingDate = data['bookingDate'] ?? 'TBD';
                            final bookingTime = data['bookingTime'] ?? 'TBD';
                            final address = data['address'] ?? 'No Address';

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
                                  Text(
                                    clientName,
                                    style: const TextStyle(
                                      color: textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Address: $address',
                                    style: const TextStyle(color: textMuted),
                                  ),
                                  Text(
                                    'Schedule: $bookingDate at $bookingTime',
                                    style: const TextStyle(color: textMuted),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          onPressed: () => _updateBookingStatus(
                                            context,
                                            doc.id,
                                            'Accepted',
                                          ),
                                          child: const Text('Accept'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          onPressed: () => _updateBookingStatus(
                                            context,
                                            doc.id,
                                            'Declined',
                                          ),
                                          child: const Text('Decline'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

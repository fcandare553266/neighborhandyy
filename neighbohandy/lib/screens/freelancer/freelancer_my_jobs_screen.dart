import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'accepted_bookings_screen.dart';
import 'job_detail_screen.dart';

class FreelancerMyJobsScreen extends StatelessWidget {
  final String freelancerId;

  const FreelancerMyJobsScreen({
    super.key,
    required this.freelancerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: const Text(
          'My Active Jobs',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: darkBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: lightAccent),
            tooltip: 'View Booked Schedule',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AcceptedBookingsScreen(freelancerId: freelancerId),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.work_off_outlined, size: 48, color: textMuted),
                    const SizedBox(height: 12),
                    const Text(
                      'No active jobs right now.',
                      style: TextStyle(color: textMuted, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightAccent,
                        foregroundColor: darkBackground,
                      ),
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Check Schedule History'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AcceptedBookingsScreen(freelancerId: freelancerId),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data();
                final clientName = data['clientName'] ?? 'Client';
                final serviceType = data['serviceType'] ?? 'Job Request';
                final bookingDate = data['bookingDate'] ?? 'Date TBD';
                final bookingTime = data['bookingTime'] ?? 'Time TBD';

                return Card(
                  color: darkCard,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: darkCardBorder),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      '$clientName — $serviceType',
                      style: const TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Row(
                        children: [
                          const Icon(Icons.event, size: 14, color: lightAccent),
                          const SizedBox(width: 6),
                          Text(
                            '$bookingDate at $bookingTime',
                            style: const TextStyle(color: textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: textMuted),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobDetailScreen(
                            bookingId: doc.id,
                            bookingData: data,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
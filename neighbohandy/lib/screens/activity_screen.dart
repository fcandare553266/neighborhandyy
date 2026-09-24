import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/app_notification.dart';

import 'package:provider/provider.dart';

import '../providers/app_state_provider.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  // Collection reference for Firestore CRUD operations
  CollectionReference get _bookingsRef =>
      FirebaseFirestore.instance.collection('bookings');

  // READ: Fetch real-time stream of bookings ordered by creation time
  Stream<QuerySnapshot> _getBookingsStream() {
    return _bookingsRef.orderBy('createdAt', descending: true).snapshots();
  }

  // UPDATE: Change status of a booking document by ID
  Future<void> _updateBookingStatus(
    BuildContext context,
    String docId,
    String newStatus,
  ) async {
    try {
      await _bookingsRef.doc(docId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Booking marked as $newStatus')));

        // Fix: Removed () after AppStateProvider and safely checked property
        final appState = context.read<AppStateProvider>();
        final bool notificationsEnabled = appState.notificationsEnabled;

        if (notificationsEnabled) {
          await showAppNotification(
            context,
            'Your booking status changed to $newStatus.',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update booking: $e')));
      }
    }
  }

  // DELETE: Remove booking document by ID
  Future<void> _cancelBooking(BuildContext context, String docId) async {
    try {
      await _bookingsRef.doc(docId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Booking cancelled')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to cancel booking: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot>(
        stream: _getBookingsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Your bookings',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  color: ink,
                ),
              ),
              const SizedBox(height: 6),
              const Text('Track requests and upcoming visits.'),
              const SizedBox(height: 20),
              if (docs.isEmpty)
                _emptyState()
              else
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final providerName = data['provider'] ?? 'Unknown Provider';
                  final serviceName = data['service'] ?? 'General Service';
                  final city = data['city'] ?? '';
                  final status = data['status'] ?? 'pending';

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: mint,
                        child: Icon(Icons.schedule, color: ink),
                      ),
                      title: Text(
                        providerName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('$serviceName • $city'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text(
                              status,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: status == 'completed'
                                ? Colors.green.shade100
                                : status == 'confirmed'
                                    ? Colors.blue.shade100
                                    : Colors.amber.shade100,
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'cancel') {
                                _cancelBooking(context, doc.id);
                              } else {
                                _updateBookingStatus(context, doc.id, value);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'confirmed',
                                child: Text('Mark as Confirmed'),
                              ),
                              const PopupMenuItem(
                                value: 'completed',
                                child: Text('Mark as Completed'),
                              ),
                              const PopupMenuDivider(),
                              const PopupMenuItem(
                                value: 'cancel',
                                child: Text(
                                  'Cancel Booking',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      );

  Widget _emptyState() => Container(
        padding: const EdgeInsets.symmetric(vertical: 55),
        child: const Column(
          children: [
            Icon(Icons.event_note_outlined, size: 60, color: Color(0xFFB5C4BE)),
            SizedBox(height: 12),
            Text(
              'No bookings yet',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 4),
            Text('Your neighborhood helpers will appear here.'),
          ],
        ),
      );
}
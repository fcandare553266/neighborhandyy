import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/status_chip.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});
  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid =
          FirebaseAuth.instance.currentUser?.uid ??
          context.read<AuthProvider>().currentUser?.uid;
      if (uid != null) {
        context.read<BookingProvider>().listenToClientBookings(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<BookingProvider>().myBookings;
    final error = context.watch<BookingProvider>().errorMessage;
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load bookings from Firebase.\n$error',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : bookings.isEmpty
          ? Center(
              child: Text(
                'No bookings yet — browse a category to book a freelancer.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, i) {
                final b = bookings[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      b.freelancerName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${b.category} · ${DateFormat.yMMMd().format(b.date)}, ${b.time}',
                    ),
                    trailing: StatusChip(status: b.status),
                  ),
                );
              },
            ),
    );
  }
}

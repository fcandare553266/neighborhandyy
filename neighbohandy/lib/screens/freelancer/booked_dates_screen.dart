import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/booking_request_card.dart';

class BookedDatesScreen extends StatefulWidget {
  const BookedDatesScreen({super.key});
  @override
  State<BookedDatesScreen> createState() => _BookedDatesScreenState();
}

class _BookedDatesScreenState extends State<BookedDatesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final uid = auth.currentFreelancer?.uid ?? auth.currentUser?.uid;
      if (uid != null) {
        context.read<BookingProvider>().listenToFreelancerBookedDates(uid);
      }
    });
  }

  Map<String, List<BookingModel>> _groupByDate(List<BookingModel> bookings) {
    final grouped = <String, List<BookingModel>>{};
    for (final b in bookings) {
      final key = DateFormat.yMMMd().format(b.date);
      grouped.putIfAbsent(key, () => []).add(b);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<BookingProvider>().bookedDates;
    final error = context.watch<BookingProvider>().errorMessage;
    final grouped = _groupByDate(bookings);

    return Scaffold(
      appBar: AppBar(title: const Text('Booked Dates')),
      body: error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load confirmed bookings from Firebase.\n$error',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : grouped.isEmpty
          ? Center(
              child: Text(
                'No confirmed bookings yet.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: grouped.entries.expand((entry) {
                return [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 8),
                    child: Text(
                      entry.key.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  ...entry.value.map((b) => BookingRequestCard(booking: b)),
                ];
              }).toList(),
            ),
    );
  }
}

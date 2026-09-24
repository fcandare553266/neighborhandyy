import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/booking_request_card.dart';

class JobRequestsScreen extends StatefulWidget {
  const JobRequestsScreen({super.key});
  @override
  State<JobRequestsScreen> createState() => _JobRequestsScreenState();
}

class _JobRequestsScreenState extends State<JobRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid != null) context.read<BookingProvider>().listenToFreelancerRequests(uid);
    });
  }

  Future<void> _refresh() async {
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) context.read<BookingProvider>().listenToFreelancerRequests(uid);
  }

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<BookingProvider>().pendingRequests;
    final bookingProvider = context.read<BookingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Job Requests')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: requests.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Text('📭  No pending requests.',
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                itemBuilder: (context, i) {
                  final b = requests[i];
                  return BookingRequestCard(
                    booking: b,
                    onAccept: () => bookingProvider.acceptBooking(b.id),
                    onDecline: () => bookingProvider.declineBooking(b.id),
                  );
                },
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/booking_model.dart';
import '../../models/freelancer_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class BookingFormScreen extends StatefulWidget {
  final FreelancerModel freelancer;
  const BookingFormScreen({super.key, required this.freelancer});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  DateTime? _date;
  TimeOfDay? _time;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _confirm() async {
    if (_date == null || _time == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a date and time')));
      return;
    }
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    final booking = BookingModel(
      id: '', // Firestore assigns this on create
      clientId: user.uid,
      clientName: user.name,
      clientAddress: user.address.isNotEmpty ? user.address : user.city,
      clientPhone: user.phone,
      freelancerId: widget.freelancer.uid,
      freelancerName: widget.freelancer.companyName,
      category: widget.freelancer.category,
      date: _date!,
      time: _time!.format(context),
    );

    final ok = await context.read<BookingProvider>().createBooking(booking);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Booking request sent!')));
      Navigator.of(context).popUntil((r) => r.isFirst);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.read<BookingProvider>().errorMessage ?? 'Failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final submitting = context.watch<BookingProvider>().isSubmitting;

    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.freelancer.companyName}')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _PickerField(
              label: 'Service date',
              value: _date != null ? DateFormat.yMMMd().format(_date!) : 'Select date',
              icon: Icons.calendar_today_outlined,
              onTap: _pickDate,
            ),
            _PickerField(
              label: 'Service time',
              value: _time != null ? _time!.format(context) : 'Select time',
              icon: Icons.access_time,
              onTap: _pickTime,
            ),
            const SizedBox(height: 10),
            const Text('From your profile', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 10),
            LockedField(label: 'Full name', value: user?.name ?? ''),
            LockedField(label: 'Address', value: user?.address.isNotEmpty == true ? user!.address : (user?.city ?? '')),
            LockedField(label: 'Phone number', value: user?.phone ?? ''),
            const SizedBox(height: 16),
            PrimaryButton(label: 'Confirm booking', onPressed: _confirm, loading: submitting),
          ],
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerField({required this.label, required this.value, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.bodySmall),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}

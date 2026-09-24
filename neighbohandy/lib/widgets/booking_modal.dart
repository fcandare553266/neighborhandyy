import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../core/app_notification.dart';
import '../models/provider_profile.dart';
import '../providers/app_state_provider.dart';

class BookingModal extends StatefulWidget {
  final ProviderProfile provider;
  const BookingModal({super.key, required this.provider});

  @override
  State<BookingModal> createState() => _BookingModalState();
}

class _BookingModalState extends State<BookingModal> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  int _estimatedHours = 2;
  String _paymentMethod = 'GCash';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final totalCost = widget.provider.hourlyRate * _estimatedHours;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Book ${widget.provider.name}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                widget.provider.service,
                style: const TextStyle(color: Colors.grey),
              ),
              const Divider(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Saved Primary Address'),
                subtitle: Text(appState.activeAddress),
                leading: const Icon(Icons.location_on, color: Colors.redAccent),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(_selectedTime.format(context)),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (picked != null) setState(() => _selectedTime = picked);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _estimatedHours,
                decoration: const InputDecoration(
                  labelText: 'Estimated Duration (Hours)',
                  border: OutlineInputBorder(),
                ),
                items: [1, 2, 3, 4, 5, 8].map((h) {
                  return DropdownMenuItem(value: h, child: Text('$h Hour(s)'));
                }).toList(),
                onChanged: (val) => setState(() => _estimatedHours = val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                ),
                items: ['GCash', 'Cash on Delivery', 'Credit/Debit Card'].map((method) {
                  return DropdownMenuItem(value: method, child: Text(method));
                }).toList(),
                onChanged: (val) => setState(() => _paymentMethod = val!),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Estimated Cost:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('₱${totalCost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  final scheduledDateTime = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  );

                  final newBooking = Booking(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    providerName: widget.provider.name,
                    serviceName: widget.provider.service,
                    clientAddress: appState.activeAddress,
                    city: appState.activeCity,
                    scheduledTime: scheduledDateTime,
                    totalCost: totalCost,
                    paymentMethod: _paymentMethod,
                  );

                  appState.addBooking(newBooking);
                  if (appState.notificationsEnabled) {
                    await showAppNotification(
                      context,
                      'Your booking request for ${widget.provider.service} was sent successfully.',
                    );
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking request sent successfully!')),
                  );
                },
                child: const Text('Confirm & Book Service'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
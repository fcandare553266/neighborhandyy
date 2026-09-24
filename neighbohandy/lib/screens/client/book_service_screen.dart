import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'booking_confirmation_screen.dart';

class BookServiceScreen extends StatefulWidget {
  final Map<String, dynamic>? freelancer;
  final String? address;

  const BookServiceScreen({super.key, this.freelancer, this.address});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  String _selectedPayment = 'Cash';
  String? _selectedService;
  String? _selectedAddress;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.freelancer != null &&
        widget.freelancer!['serviceRole'] != null) {
      _selectedService = widget.freelancer!['serviceRole'];
    } else if (widget.freelancer != null &&
        widget.freelancer!['service'] != null) {
      _selectedService = widget.freelancer!['service'];
    }
    if (widget.address != null) {
      _selectedAddress = widget.address;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (_selectedService == null ||
        _selectedAddress == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required booking fields.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final formattedDate =
          '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}';
      final formattedTime = _selectedTime!.format(context);
      final rate =
          (widget.freelancer?['hourlyRate'] ?? widget.freelancer?['rate'] ?? 0)
              .toDouble();

      final bookingData = {
        'clientId': user?.uid ?? '',
        'clientName':
            user?.displayName ?? user?.email?.split('@').first ?? 'Resident',
        'clientAddress': _selectedAddress,
        'clientPhone': '',
        'freelancerId':
            widget.freelancer?['id'] ?? widget.freelancer?['uid'] ?? '',
        'freelancerName': widget.freelancer?['name'] ?? 'Freelancer',
        'category': _selectedService,
        'date': _selectedDate!.toIso8601String(),
        'time': formattedTime,
        'serviceType': _selectedService,
        'address': _selectedAddress,
        'bookingDate': formattedDate,
        'bookingTime': formattedTime,
        'paymentMethod': _selectedPayment,
        'notes': _notesController.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await FirebaseFirestore.instance
          .collection('bookings')
          .add(bookingData);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmationScreen(
              freelancerName: widget.freelancer?['name'] ?? 'Freelancer',
              serviceType: _selectedService ?? 'Service',
              dateStr: formattedDate,
              timeStr: formattedTime,
              address: _selectedAddress ?? '',
              totalPrice: rate.round(),
              bookingId: docRef.id,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating booking: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rate =
        (widget.freelancer?['hourlyRate'] ?? widget.freelancer?['rate'] ?? 0)
            .toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Book a Service',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.freelancer != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              widget.freelancer!['photoUrl'] != null &&
                                  widget.freelancer!['photoUrl']
                                      .toString()
                                      .isNotEmpty
                              ? NetworkImage(widget.freelancer!['photoUrl'])
                              : null,
                          child:
                              widget.freelancer!['photoUrl'] == null ||
                                  widget.freelancer!['photoUrl']
                                      .toString()
                                      .isEmpty
                              ? Text(
                                  (widget.freelancer!['name'] ?? 'F')[0],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.freelancer!['name'] ?? 'Freelancer',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '₱$rate/hr · ★ ${widget.freelancer!['rating'] ?? 5.0}',
                                style: TextStyle(
                                  color: theme.hintColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              _buildLabel('Service needed'),
              _buildDropdown(
                hint: 'Select a service',
                value: _selectedService,
                items: widget.freelancer?['serviceRole'] != null
                    ? [widget.freelancer!['serviceRole'].toString()]
                    : widget.freelancer?['service'] != null
                    ? [widget.freelancer!['service'].toString()]
                    : ['Cleaning', 'Repair', 'Plumbing', 'Electrical'],
                onChanged: (val) => setState(() => _selectedService = val),
              ),
              const SizedBox(height: 16),

              _buildLabel('Service address'),
              _buildDropdown(
                hint: 'Select an address',
                value: _selectedAddress,
                items: widget.address != null
                    ? [widget.address!]
                    : ['Home Address', 'Office Address', 'Custom Location'],
                onChanged: (val) => setState(() => _selectedAddress = val),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Date'),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: _buildInputBox(
                            _selectedDate == null
                                ? 'mm/dd/yyyy'
                                : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                            Icons.calendar_today,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Time'),
                        GestureDetector(
                          onTap: () => _selectTime(context),
                          child: _buildInputBox(
                            _selectedTime == null
                                ? '--:-- --'
                                : _selectedTime!.format(context),
                            Icons.access_time,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Payment method'),
              Row(
                children: [
                  _buildPaymentChip('Cash'),
                  const SizedBox(width: 8),
                  _buildPaymentChip('GCash'),
                  const SizedBox(width: 8),
                  _buildPaymentChip('Card'),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Notes for the freelancer (optional)'),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add any details they should know',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estimated total',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        '₱${rate.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submitBooking,
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Confirm Booking',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: items.contains(value) ? value : null,
          hint: Text(hint, style: const TextStyle(fontSize: 13)),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInputBox(String hint, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(hint, style: const TextStyle(fontSize: 13)),
          Icon(icon, size: 18),
        ],
      ),
    );
  }

  Widget _buildPaymentChip(String method) {
    final isSelected = _selectedPayment == method;
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPayment = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor : theme.cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? theme.primaryColor : theme.dividerColor,
            ),
          ),
          child: Center(
            child: Text(
              method,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : theme.textTheme.bodyMedium?.color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

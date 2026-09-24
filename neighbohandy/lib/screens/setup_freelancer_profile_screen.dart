import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/provider_profile.dart';
import '../providers/app_state_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/city_picker_sheet.dart';

class SetupFreelancerProfileScreen extends StatefulWidget {
  const SetupFreelancerProfileScreen({super.key});

  @override
  State<SetupFreelancerProfileScreen> createState() =>
      _SetupFreelancerProfileScreenState();
}

class _SetupFreelancerProfileScreenState
    extends State<SetupFreelancerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceController = TextEditingController();
  final _rateController = TextEditingController();
  final _logoUrlController = TextEditingController();
  String _selectedCity = 'Quezon City';
  bool _saving = false;

  @override
  void dispose() {
    _serviceController.dispose();
    _rateController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Complete Freelancer Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your application has been approved!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please complete your professional service profile below.',
              ),
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(_logoUrlController.text),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton.filled(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Logo selector clicked. Default image set.',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _serviceController,
                decoration: const InputDecoration(
                  labelText:
                      'Primary Service Offered (e.g., Plumbing, Electrician)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Hourly Service Rate (₱)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Required';
                  }
                  if (double.tryParse(val) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Operating Service City'),
                subtitle: Text(_selectedCity),
                trailing: TextButton(
                  child: const Text('Select City'),
                  onPressed: () async {
                    final city = await showModalBottomSheet<String>(
                      context: context,
                      builder: (ctx) =>
                          CityPickerSheet(activeCity: _selectedCity),
                    );
                    if (city != null) setState(() => _selectedCity = city);
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _saving
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) return;
                          setState(() => _saving = true);
                          try {
                            final service = _serviceController.text.trim();
                            final rate =
                                double.tryParse(_rateController.text) ?? 300.0;
                            final firestoreService = FirestoreService();
                            await firestoreService.saveProviderProfile(
                              userId: user.uid,
                              service: service,
                              hourlyRate: rate,
                              city: _selectedCity,
                              imageUrl: _logoUrlController.text.trim(),
                            );
                            final approvedApp = await FirebaseFirestore.instance
                                .collection('freelancer_applications')
                                .where('userId', isEqualTo: user.uid)
                                .where('status', isEqualTo: 'approved')
                                .limit(1)
                                .get();
                            if (approvedApp.docs.isNotEmpty) {
                              await firestoreService.updateApplicationStatus(
                                approvedApp.docs.first.id,
                                'completed',
                              );
                            }

                            if (!context.mounted) return;
                            appState.completeFreelancerProfile(
                              ProviderProfile(
                                id: user.uid,
                                name: user.displayName ?? 'Freelancer',
                                service: service,
                                hourlyRate: rate,
                                city: _selectedCity,
                                rating: 5.0,
                                imageUrl: _logoUrlController.text,
                              ),
                            );
                            Navigator.pop(context);
                          } catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Could not save profile: $error'),
                              ),
                            );
                          } finally {
                            if (mounted) setState(() => _saving = false);
                          }
                        }
                      },
                child: const Text('Save & Open Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

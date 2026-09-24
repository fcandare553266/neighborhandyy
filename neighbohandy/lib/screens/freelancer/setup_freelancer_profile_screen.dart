import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../models/user_role.dart';
import '../../providers/app_state_provider.dart';

class SetupFreelancerProfileScreen extends StatefulWidget {
  const SetupFreelancerProfileScreen({super.key});

  @override
  State<SetupFreelancerProfileScreen> createState() =>
      _SetupFreelancerProfileScreenState();
}

class _SetupFreelancerProfileScreenState
    extends State<SetupFreelancerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceRoleController = TextEditingController();
  final _operatingCityController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _serviceRoleController.dispose();
    _operatingCityController.dispose();
    _hourlyRateController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final role = _serviceRoleController.text.trim();
      final city = _operatingCityController.text.trim();
      final rate = double.tryParse(_hourlyRateController.text.trim()) ?? 0.0;
      final bio = _bioController.text.trim();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'role': 'freelancer',
        'serviceRole': role,
        'operatingCity': city,
        'hourlyRate': rate,
        'bio': bio,
        'isFreelancerSetupComplete': true,
      }, SetOptions(merge: true));

      if (mounted) {
        final provider = Provider.of<AppStateProvider>(context, listen: false);
        provider.setRole(UserRole.freelancer);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Freelancer profile saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: const Text('Setup Freelancer Profile'),
        backgroundColor: darkBackground,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Freelancer Details',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _serviceRoleController,
                  style: const TextStyle(color: textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Service Role (e.g., Plumber, Electrician)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _operatingCityController,
                  style: const TextStyle(color: textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Operating City',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hourlyRateController,
                  style: const TextStyle(color: textPrimary),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Hourly Rate (\$)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  style: const TextStyle(color: textPrimary),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Bio / Short Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Save & Become Freelancer',
                            style: TextStyle(
                              color: darkBackground,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
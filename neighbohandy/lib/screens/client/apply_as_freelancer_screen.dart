import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/freelancer_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class ApplyAsFreelancerScreen extends StatefulWidget {
  const ApplyAsFreelancerScreen({super.key});
  @override
  State<ApplyAsFreelancerScreen> createState() => _ApplyAsFreelancerScreenState();
}

class _ApplyAsFreelancerScreenState extends State<ApplyAsFreelancerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyName = TextEditingController();
  final _contactPerson = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _category = TextEditingController();
  final _rate = TextEditingController();
  bool _saving = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    final profile = FreelancerModel(
      uid: user.uid,
      companyName: _companyName.text.trim(),
      contactPerson: _contactPerson.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      city: _city.text.trim(),
      category: _category.text.trim(),
      ratePerHour: double.tryParse(_rate.text) ?? 0,
      verified: false, // an admin approves this — see the Admin Oversight flow
    );
    final ok = await context.read<AuthProvider>().applyAsFreelancer(profile);
    setState(() => _saving = false);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted — pending admin verification')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply as Freelancer')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AppTextField(label: 'Company / service name', controller: _companyName,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              AppTextField(label: 'Contact person', controller: _contactPerson,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              AppTextField(label: 'Phone number', controller: _phone, keyboardType: TextInputType.phone),
              AppTextField(label: 'Address', controller: _address),
              AppTextField(label: 'Operating city', controller: _city,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              AppTextField(label: 'Service category (e.g. plumbing)', controller: _category),
              AppTextField(label: 'Rate per hour (₱)', controller: _rate, keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              PrimaryButton(label: 'Submit application', onPressed: _submit, loading: _saving),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class FreelancerEditProfileScreen extends StatefulWidget {
  const FreelancerEditProfileScreen({super.key});
  @override
  State<FreelancerEditProfileScreen> createState() => _FreelancerEditProfileScreenState();
}

class _FreelancerEditProfileScreenState extends State<FreelancerEditProfileScreen> {
  late final TextEditingController _companyName;
  late final TextEditingController _contactPerson;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _city;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final f = context.read<AuthProvider>().currentFreelancer;
    _companyName = TextEditingController(text: f?.companyName);
    _contactPerson = TextEditingController(text: f?.contactPerson);
    _phone = TextEditingController(text: f?.phone);
    _address = TextEditingController(text: f?.address);
    _city = TextEditingController(text: f?.city);
  }

  Future<void> _pickPhoto() async {
    // TODO: wire to image_picker + Firebase Storage upload, then
    // context.read<AuthProvider>().updateFreelancerProfile({'photoUrl': uploadedUrl});
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<AuthProvider>().updateFreelancerProfile({
      'companyName': _companyName.text.trim(),
      'contactPerson': _contactPerson.text.trim(),
      'phone': _phone.text.trim(),
      'address': _address.text.trim(),
      'city': _city.text.trim(),
    });
    setState(() => _saving = false);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = context.watch<AuthProvider>().currentFreelancer?.photoUrl;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 37,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null ? const Icon(Icons.business, size: 28) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickPhoto,
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.camera_alt, size: 13, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppTextField(label: 'Company name', controller: _companyName),
            AppTextField(label: 'Contact person', controller: _contactPerson),
            AppTextField(label: 'Phone number', controller: _phone, keyboardType: TextInputType.phone),
            AppTextField(label: 'Address', controller: _address),
            // TODO: swap for DropdownButtonFormField sourced from your
            // operating-cities list, per the original spec.
            AppTextField(label: 'Active city', controller: _city),
            const SizedBox(height: 10),
            PrimaryButton(label: 'Save changes', onPressed: _save, loading: _saving),
          ],
        ),
      ),
    );
  }
}

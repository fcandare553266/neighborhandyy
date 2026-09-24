import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _city;
  late final TextEditingController _phone;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _name = TextEditingController(text: user?.name);
    _address = TextEditingController(text: user?.address);
    _city = TextEditingController(text: user?.city);
    _phone = TextEditingController(text: user?.phone);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<AuthProvider>().updateClientProfile({
      'name': _name.text.trim(),
      'address': _address.text.trim(),
      'city': _city.text.trim(),
      'phone': _phone.text.trim(),
    });
    setState(() => _saving = false);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextField(label: 'Full name', controller: _name),
            AppTextField(label: 'Address', controller: _address),
            // TODO: swap for a city DropdownButtonFormField sourced from
            // your operating-cities list, to keep it consistent with how
            // freelancers pick their city.
            AppTextField(label: 'City', controller: _city),
            AppTextField(label: 'Phone number', controller: _phone, keyboardType: TextInputType.phone),
            const SizedBox(height: 10),
            PrimaryButton(label: 'Save changes', onPressed: _save, loading: _saving),
          ],
        ),
      ),
    );
  }
}

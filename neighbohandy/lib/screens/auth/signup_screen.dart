import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import 'role_select_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _agreed = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms of Service')),
      );
      return;
    }

    final role = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const RoleSelectScreen()));
    if (role == null || !mounted) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.signUp(
      name: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      phone: _phone.text.trim(),
      role: role,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Sign up failed')),
      );
    } else if (ok && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create your account')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 8),
                AppTextField(
                  label: 'Full name',
                  controller: _name,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                AppTextField(
                  label: 'Email',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Enter a valid email'
                      : null,
                ),
                AppTextField(
                  label: 'Mobile number',
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                AppTextField(
                  label: 'Password',
                  controller: _password,
                  obscure: _hidePassword,
                  suffixIcon: IconButton(
                    tooltip: _hidePassword ? 'Show password' : 'Hide password',
                    icon: Icon(
                      _hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _hidePassword = !_hidePassword),
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Minimum 6 characters'
                      : null,
                ),
                AppTextField(
                  label: 'Confirm password',
                  controller: _confirm,
                  obscure: _hideConfirmPassword,
                  suffixIcon: IconButton(
                    tooltip: _hideConfirmPassword ? 'Show password' : 'Hide password',
                    icon: Icon(
                      _hideConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _hideConfirmPassword = !_hideConfirmPassword),
                  ),
                  validator: (v) =>
                      v != _password.text ? 'Passwords do not match' : null,
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _agreed,
                  onChanged: (v) => setState(() => _agreed = v ?? false),
                  title: const Text(
                    'I agree to the Terms of Service and Privacy Policy',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: 'Create account',
                  onPressed: _submit,
                  loading: auth.isLoading,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

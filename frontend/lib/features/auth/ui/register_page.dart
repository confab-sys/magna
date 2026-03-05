import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magna_coders/core/auth/auth_service.dart';
import 'package:magna_coders/shared/widgets/primary_button.dart';
import 'package:magna_coders/shared/widgets/app_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _onRegister() async {
    setState(() => _loading = true);
    try {
      final ok = await _auth.register(email: _email.text.trim(), password: _password.text, name: _name.text.trim());
      if (ok && mounted) {
        context.go('/feed');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration failed')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppTextField(controller: _name, label: 'Name'),
            const SizedBox(height: 16),
            AppTextField(controller: _email, label: 'Email', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            AppTextField(controller: _password, label: 'Password', obscureText: true),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Register', onPressed: _onRegister, loading: _loading),
            const SizedBox(height: 12),
            TextButton(onPressed: () => context.go('/login'), child: const Text('Already have an account?')),
          ],
        ),
      ),
    );
  }
}

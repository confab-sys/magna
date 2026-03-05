import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magna_coders/core/auth/auth_service.dart';
import 'package:magna_coders/shared/widgets/primary_button.dart';
import 'package:magna_coders/shared/widgets/app_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _onLogin() async {
    setState(() => _loading = true);
    try {
      final ok = await _auth.login(_email.text.trim(), _password.text);
      if (ok && mounted) {
        context.go('/feed');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed')));
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
            AppTextField(controller: _email, label: 'Email', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            AppTextField(controller: _password, label: 'Password', obscureText: true),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Login', onPressed: _onLogin, loading: _loading),
            const SizedBox(height: 12),
            TextButton(onPressed: () => context.go('/register'), child: const Text('Create account')),
          ],
        ),
      ),
    );
  }
}

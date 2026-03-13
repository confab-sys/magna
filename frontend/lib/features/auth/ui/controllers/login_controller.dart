import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:magna_coders/core/auth/auth_service.dart';

class LoginController extends ChangeNotifier {
  final AuthService _auth;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _loading = false;
  bool _showPassword = false;
  bool _hasTriedSubmit = false;

  String? _emailError;
  String? _passwordError;
  String? _formError;

  bool get loading => _loading;
  bool get showPassword => _showPassword;

  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get formError => _formError;

  LoginController({AuthService? auth}) : _auth = auth ?? AuthService() {
    emailController.addListener(_validateEmailIfNeeded);
    passwordController.addListener(_validatePasswordIfNeeded);
  }

  void togglePasswordVisibility() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  String? _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Email is required';
    // Lightweight email check (client-side).
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(trimmed)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    return null;
  }

  void _validateEmailIfNeeded() {
    if (!_hasTriedSubmit) return;
    _emailError = _validateEmail(emailController.text);
    notifyListeners();
  }

  void _validatePasswordIfNeeded() {
    if (!_hasTriedSubmit) return;
    _passwordError = _validatePassword(passwordController.text);
    notifyListeners();
  }

  bool validate({bool markSubmitted = true}) {
    if (markSubmitted) _hasTriedSubmit = true;
    _emailError = _validateEmail(emailController.text);
    _passwordError = _validatePassword(passwordController.text);
    _formError = null;
    notifyListeners();
    return _emailError == null && _passwordError == null;
  }

  Future<bool> submit() async {
    if (!validate(markSubmitted: true)) return false;
    if (_loading) return false;

    _setLoading(true);
    try {
      final ok = await _auth.login(
        emailController.text.trim(),
        passwordController.text,
      );
      if (!ok) {
        _formError = 'Login failed';
        notifyListeners();
      }
      return ok;
    } catch (_) {
      _formError = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> startGoogle() => _auth.startOAuth('google');
  Future<void> startGithub() => _auth.startOAuth('github');

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}


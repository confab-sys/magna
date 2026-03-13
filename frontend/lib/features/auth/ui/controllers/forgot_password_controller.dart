import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:magna_coders/core/auth/auth_service.dart';

class ForgotPasswordController extends ChangeNotifier {
  final AuthService _auth;
  final emailController = TextEditingController();

  bool _loading = false;
  bool _sent = false;
  bool _hasTriedSubmit = false;
  String? _emailError;
  String? _formError;

  bool get loading => _loading;
  bool get sent => _sent;
  String? get emailError => _emailError;
  String? get formError => _formError;

  ForgotPasswordController({AuthService? auth}) : _auth = auth ?? AuthService() {
    emailController.addListener(_validateEmailIfNeeded);
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  String? _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(trimmed)) return 'Enter a valid email';
    return null;
  }

  void _validateEmailIfNeeded() {
    if (!_hasTriedSubmit) return;
    _emailError = _validateEmail(emailController.text);
    notifyListeners();
  }

  bool validate({bool markSubmitted = true}) {
    if (markSubmitted) _hasTriedSubmit = true;
    _emailError = _validateEmail(emailController.text);
    _formError = null;
    notifyListeners();
    return _emailError == null;
  }

  Future<void> submit() async {
    if (!validate(markSubmitted: true)) return;
    if (_loading) return;

    _setLoading(true);
    try {
      await _auth.requestPasswordReset(emailController.text.trim());
      _sent = true;
      notifyListeners();
    } catch (_) {
      // Do not leak account existence. Still show the same confirmation UX.
      _sent = true;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:magna_coders/core/auth/auth_service.dart';

class RegisterController extends ChangeNotifier {
  final AuthService _auth;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _formError;

  bool get loading => _loading;
  bool get showPassword => _showPassword;
  bool get showConfirmPassword => _showConfirmPassword;

  String? get usernameError => _usernameError;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get confirmPasswordError => _confirmPasswordError;
  String? get formError => _formError;

  RegisterController({AuthService? auth}) : _auth = auth ?? AuthService() {
    usernameController.addListener(_validateUsernameIfNeeded);
    emailController.addListener(_validateEmailIfNeeded);
    passwordController.addListener(_validatePasswordIfNeeded);
    confirmPasswordController.addListener(_validateConfirmPasswordIfNeeded);
  }

  void togglePasswordVisibility() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _showConfirmPassword = !_showConfirmPassword;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  bool _hasTriedSubmit = false;

  void _validateUsernameIfNeeded() {
    if (!_hasTriedSubmit) return;
    _usernameError = _validateUsername(usernameController.text);
    notifyListeners();
  }

  void _validateEmailIfNeeded() {
    if (!_hasTriedSubmit) return;
    _emailError = _validateEmail(emailController.text);
    notifyListeners();
  }

  void _validatePasswordIfNeeded() {
    if (!_hasTriedSubmit) return;
    _passwordError = _validatePassword(passwordController.text);
    _confirmPasswordError =
        _validateConfirmPassword(confirmPasswordController.text);
    notifyListeners();
  }

  void _validateConfirmPasswordIfNeeded() {
    if (!_hasTriedSubmit) return;
    _confirmPasswordError =
        _validateConfirmPassword(confirmPasswordController.text);
    notifyListeners();
  }

  String? _validateUsername(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Username is required';
    if (trimmed.contains(' ')) return 'Username cannot contain spaces';
    return null;
  }

  String? _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmed)) return 'Please enter a valid email address';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? _validateConfirmPassword(String value) {
    if (value.isEmpty) return 'Confirm password is required';
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  bool validate({bool markSubmitted = true}) {
    if (markSubmitted) _hasTriedSubmit = true;

    _usernameError = _validateUsername(usernameController.text);
    _emailError = _validateEmail(emailController.text);
    _passwordError = _validatePassword(passwordController.text);
    _confirmPasswordError = _validateConfirmPassword(confirmPasswordController.text);
    _formError = null;
    notifyListeners();

    return _usernameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  Future<bool> submit() async {
    if (!validate(markSubmitted: true)) return false;
    if (_loading) return false;

    _setLoading(true);
    try {
      final ok = await _auth.registerWithUsername(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (!ok) {
        _formError = 'Registration failed';
        notifyListeners();
      }
      return ok;
    } catch (e) {
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
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}


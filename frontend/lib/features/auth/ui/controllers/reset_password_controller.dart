import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:magna_coders/core/auth/auth_service.dart';

class ResetPasswordController extends ChangeNotifier {
  final AuthService _auth;
  final String token;

  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _hasTriedSubmit = false;

  String? _newPasswordError;
  String? _confirmPasswordError;
  String? _formError;

  bool get loading => _loading;
  bool get showNewPassword => _showNewPassword;
  bool get showConfirmPassword => _showConfirmPassword;

  String? get newPasswordError => _newPasswordError;
  String? get confirmPasswordError => _confirmPasswordError;
  String? get formError => _formError;

  ResetPasswordController({
    required this.token,
    AuthService? auth,
  }) : _auth = auth ?? AuthService() {
    newPasswordController.addListener(_validateNewPasswordIfNeeded);
    confirmPasswordController.addListener(_validateConfirmPasswordIfNeeded);
  }

  void toggleNewPasswordVisibility() {
    _showNewPassword = !_showNewPassword;
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

  String? _validateNewPassword(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? _validateConfirmPassword(String value) {
    if (value.isEmpty) return 'Confirm password is required';
    if (value != newPasswordController.text) return 'Passwords do not match';
    return null;
  }

  void _validateNewPasswordIfNeeded() {
    if (!_hasTriedSubmit) return;
    _newPasswordError = _validateNewPassword(newPasswordController.text);
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

  bool validate({bool markSubmitted = true}) {
    if (markSubmitted) _hasTriedSubmit = true;
    _newPasswordError = _validateNewPassword(newPasswordController.text);
    _confirmPasswordError = _validateConfirmPassword(confirmPasswordController.text);
    _formError = null;
    notifyListeners();
    return _newPasswordError == null && _confirmPasswordError == null;
  }

  Future<bool> submit() async {
    if (!validate(markSubmitted: true)) return false;
    if (_loading) return false;

    _setLoading(true);
    try {
      await _auth.resetPassword(
        token: token,
        newPassword: newPasswordController.text,
      );
      return true;
    } catch (_) {
      _formError = 'Reset link is invalid or expired. Please request a new one.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}


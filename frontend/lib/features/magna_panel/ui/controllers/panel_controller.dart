import 'package:flutter/foundation.dart';
import 'package:magna_coders/app/bootstrap.dart';
import 'package:magna_coders/core/auth/auth_service.dart';

class PanelController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Future<void> logout() async {
    try {
      await AppBootstrap.setLoggedOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

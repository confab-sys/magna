import 'package:flutter/foundation.dart';

import '../../data/constants/settings_modules.dart';
import '../../data/models/settings_module_model.dart';

class SettingsController extends ChangeNotifier {
  SettingsModuleId _activeModule = SettingsModuleId.account;
  bool _isMobileDrawerOpen = false;

  SettingsModuleId get activeModule => _activeModule;
  bool get isMobileDrawerOpen => _isMobileDrawerOpen;

  List<SettingsModule> get modules => SettingsModules.all;

  void setActiveModule(SettingsModuleId id) {
    if (_activeModule == id) return;
    _activeModule = id;
    notifyListeners();
  }

  void openMobileDrawer() {
    if (_isMobileDrawerOpen) return;
    _isMobileDrawerOpen = true;
    notifyListeners();
  }

  void closeMobileDrawer() {
    if (!_isMobileDrawerOpen) return;
    _isMobileDrawerOpen = false;
    notifyListeners();
  }
}


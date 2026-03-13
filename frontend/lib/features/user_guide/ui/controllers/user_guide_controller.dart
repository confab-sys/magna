import 'package:flutter/foundation.dart';
import 'package:cross_file/cross_file.dart';

import '../../data/models/user_guide_constants.dart';
import '../../data/models/user_guide_form_model.dart';
import '../../data/user_guide_api.dart';

class UserGuideController extends ChangeNotifier {
  static const int totalSteps = 6;
  static const int bioMinLength = 40;

  int _currentStep = 0;
  UserGuideFormModel _form = const UserGuideFormModel();

  int get currentStep => _currentStep;
  UserGuideFormModel get form => _form;

  bool get canGoBack => _currentStep > 0;
  bool get canGoNext => _isStepValid(_currentStep) && _currentStep < totalSteps - 1;
  bool get isOnLastStep => _currentStep == totalSteps - 1;
  bool get canComplete => isOnLastStep && _isStepValid(_currentStep);

  void nextStep() {
    if (!canGoNext) return;
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (!canGoBack) return;
    _currentStep--;
    notifyListeners();
  }

  // Gender
  void selectGender(String value) {
    _form = _form.copyWith(gender: value);
    notifyListeners();
  }

  // Profile picture
  void setProfileImage(XFile? file) {
    _form = _form.copyWith(
      profilePicture: file,
      clearProfilePicture: file == null,
    );
    notifyListeners();
  }

  // Roles (max 2)
  void toggleRole(String roleId) {
    final current = List<String>.from(_form.roles);
    if (current.contains(roleId)) {
      current.remove(roleId);
    } else {
      if (current.length < 2) {
        current.add(roleId);
      }
    }
    _form = _form.copyWith(roles: current);
    notifyListeners();
  }

  // Goals (max 3)
  void toggleGoal(String goalId) {
    final current = List<String>.from(_form.goals);
    if (current.contains(goalId)) {
      current.remove(goalId);
    } else {
      if (current.length < 3) {
        current.add(goalId);
      }
    }
    _form = _form.copyWith(goals: current);
    notifyListeners();
  }

  // Specialisations (max 3)
  void toggleSpecialisation(String item) {
    final current = List<String>.from(_form.specialisations);
    if (current.contains(item)) {
      current.remove(item);
    } else {
      if (current.length < 3) {
        current.add(item);
      }
    }
    _form = _form.copyWith(specialisations: current);
    notifyListeners();
  }

  // Skills (max 6)
  void toggleSkill(String skill) {
    final current = List<String>.from(_form.skills);
    if (current.contains(skill)) {
      current.remove(skill);
    } else {
      if (current.length < 6) {
        current.add(skill);
      }
    }
    _form = _form.copyWith(skills: current);
    notifyListeners();
  }

  // Custom skill
  void addCustomSkill(String skill) {
    final trimmed = skill.trim();
    if (trimmed.isEmpty) return;
    final current = List<String>.from(_form.skills);
    if (current.contains(trimmed)) return;
    if (current.length >= 6) return;

    current.add(trimmed);
    _form = _form.copyWith(skills: current);
    notifyListeners();
  }

  // Availability
  void toggleAvailability(String value) {
    final current = List<String>.from(_form.availability);
    if (current.contains(value)) {
      current.remove(value);
    } else {
      current.add(value);
    }
    _form = _form.copyWith(availability: current);
    notifyListeners();
  }

  // Bio
  void setBio(String value) {
    _form = _form.copyWith(bio: value);
    notifyListeners();
  }

  // Country
  void setCountry(String value) {
    _form = _form.copyWith(
      country: value,
      clearCounty: value.toLowerCase() != 'kenya',
    );
    notifyListeners();
  }

  // County
  void setCounty(String value) {
    _form = _form.copyWith(county: value);
    notifyListeners();
  }

  bool _isStepValid(int step) {
    switch (step) {
      case 0:
        // Gender required
        return _form.gender != null && _form.gender!.isNotEmpty;
      case 1:
        // Profile picture optional
        return true;
      case 2:
        // At least 1 role required
        return _form.roles.isNotEmpty;
      case 3:
        // At least 1 goal required
        return _form.goals.isNotEmpty;
      case 4:
        // At least 1 specialisation, 1 skill, 1 availability required
        return _form.specialisations.isNotEmpty &&
            _form.skills.isNotEmpty &&
            _form.availability.isNotEmpty;
      case 5:
        // Bio, country, county (if Kenya)
        final isBioValid = _form.bio.trim().length >= bioMinLength;
        final hasCountry = _form.country != null && _form.country!.trim().isNotEmpty;
        final needsCounty = _form.country?.toLowerCase() == 'kenya';
        final hasCounty = !needsCounty || (_form.county != null && _form.county!.isNotEmpty);
        return isBioValid && hasCountry && hasCounty;
      default:
        return false;
    }
  }

  bool get isCurrentStepValid => _isStepValid(_currentStep);

  Future<bool> submit() async {
    if (!_isStepValid(5)) {
      debugPrint('❌ Final step invalid, cannot submit');
      return false;
    }
    
    try {
      debugPrint('📤 Preparing user guide submission...');
      
      final request = UserGuideRequest(
        gender: _form.gender!,
        profilePicture: _form.profilePicture,
        roles: _form.roles,
        goals: _form.goals,
        specialisations: _form.specialisations,
        skills: _form.skills,
        availability: _form.availability,
        bio: _form.bio,
        country: _form.country!,
        county: _form.county,
      );
      
      final api = UserGuideApi();
      final success = await api.submitUserGuide(request);
      
      if (success) {
        debugPrint('✅ User guide submitted successfully');
        return true;
      } else {
        debugPrint('❌ Failed to submit user guide');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error during submission: $e');
      return false;
    }
  }
}



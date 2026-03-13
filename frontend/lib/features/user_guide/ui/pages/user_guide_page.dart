import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../data/models/user_guide_constants.dart';
import '../controllers/user_guide_controller.dart';
import '../widgets/user_guide_bottom_bar.dart';
import '../widgets/user_guide_chip.dart';
import '../widgets/user_guide_option_card.dart';
import '../widgets/user_guide_progress_bar.dart';

class UserGuidePage extends StatefulWidget {
  const UserGuidePage({super.key});

  @override
  State<UserGuidePage> createState() => _UserGuidePageState();
}

class _UserGuidePageState extends State<UserGuidePage> {
  late final UserGuideController _controller;
  late final TextEditingController _bioController;
  late final TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    _controller = UserGuideController()..addListener(_onStateChanged);
    _bioController = TextEditingController(text: _controller.form.bio);
    _countryController = TextEditingController(text: _controller.form.country ?? '');

    _bioController.addListener(() {
      if (_bioController.text != _controller.form.bio) {
        _controller.setBio(_bioController.text);
      }
    });

    _countryController.addListener(() {
      final val = _countryController.text;
      if (val != (_controller.form.country ?? '')) {
        _controller.setCountry(val);
      }
    });
  }

  @override
  void dispose() {
    _bioController.dispose();
    _countryController.dispose();
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  IconData _getIconForRole(String iconName) {
    switch (iconName) {
      case 'lightbulb':
        return PhosphorIcons.lightbulb();
      case 'code':
        return PhosphorIcons.code();
      case 'palette':
        return PhosphorIcons.palette();
      case 'trending_up':
        return PhosphorIcons.trendUp();
      case 'sprout':
        return PhosphorIcons.leaf();
      case 'graduation_cap':
        return PhosphorIcons.graduationCap();
      case 'user_plus':
        return PhosphorIcons.userPlus();
      case 'line_chart':
        return PhosphorIcons.chartLineUp();
      case 'briefcase':
        return PhosphorIcons.briefcase();
      case 'headphones':
        return PhosphorIcons.headphones();
      default:
        return PhosphorIcons.user();
    }
  }

  IconData _getIconForGoal(String iconName) {
    switch (iconName) {
      case 'users':
        return PhosphorIcons.users();
      case 'handshake':
        return PhosphorIcons.handshake();
      case 'graduation_cap':
        return PhosphorIcons.graduationCap();
      case 'globe':
        return PhosphorIcons.globe();
      case 'dollar_sign':
        return PhosphorIcons.currencyDollar();
      case 'code':
        return PhosphorIcons.code();
      case 'palette':
        return PhosphorIcons.palette();
      default:
        return PhosphorIcons.star();
    }
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleNextOrComplete() async {
    if (_controller.isOnLastStep) {
      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final success = await _controller.submit();
        
        if (!mounted) return;
        Navigator.pop(context); // Close loading dialog

        if (success) {
          // Navigate to main feed
          context.go('/');
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to complete profile setup. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      _controller.nextStep();
    }
  }

  Future<void> _pickImage() async {
    try {
      const maxFileSize = 10 * 1024 * 1024; // 10MB in bytes
      
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // Important for web - gets bytes
      );

      if (result != null && result.files.isNotEmpty) {
        final fileSize = result.files.single.size;
        
        // Validate file size
        if (fileSize > maxFileSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image size must not exceed 10MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Handle web where bytes are available
        if (result.files.single.bytes != null) {
          final pickedFile = XFile.fromData(
            result.files.single.bytes!,
            name: result.files.single.name,
          );
          _controller.setProfileImage(pickedFile);
        }
        // Handle mobile/desktop where path is available
        else if (result.files.single.path != null) {
          final pickedFile = XFile(result.files.single.path!);
          _controller.setProfileImage(pickedFile);
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Widget _buildStepContent() {
    debugPrint('🟡 Building step content for step: ${_controller.currentStep}');
    switch (_controller.currentStep) {
      case 0:
        return _buildGenderStep();
      case 1:
        return _buildProfilePictureStep();
      case 2:
        return _buildRolesStep();
      case 3:
        return _buildGoalsStep();
      case 4:
        return _buildSkillsStep();
      case 5:
        return _buildFinalTouchesStep();
      default:
        // Fallback to step 0 if invalid
        return _buildGenderStep();
    }
  }

  Widget _buildGenderStep() {
    debugPrint('🔴 Rendering gender step');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How do you identify?',
          style: AppTypography.h3.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us personalize your experience.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        ...UserGuideConstants.genders.map((gender) {
          final isSelected = _controller.form.gender == gender;
          
          IconData genderIcon;
          if (gender == 'Male') {
            genderIcon = Icons.male;
          } else if (gender == 'Female') {
            genderIcon = Icons.female;
          } else {
            genderIcon = Icons.help_outline;
          }
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => _controller.selectGender(gender),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      genderIcon,
                      size: 24,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        gender,
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildProfilePictureStep() {
    debugPrint('🟠 Rendering profile picture step');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add a profile picture',
          style: AppTypography.h3.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 8),
        Text(
          'This helps others recognize you (optional)',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        if (_controller.form.profilePicture != null)
          FutureBuilder<Uint8List>(
            future: _controller.form.profilePicture!.readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb
                          ? Image.memory(
                              snapshot.data!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(_controller.form.profilePicture!.path),
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }
              return const SizedBox(
                width: 120,
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: Icon(PhosphorIcons.user()),
          label: const Text('Choose from gallery'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        if (_controller.form.profilePicture != null) ...[
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _controller.setProfileImage(null),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('Remove'),
          ),
        ],
      ],
    );
  }

  Widget _buildRolesStep() {
    debugPrint('🟡 Rendering roles step');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What describes you best?',
          style: AppTypography.h3.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 8),
        Text(
          'Select up to 2 roles',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: UserGuideConstants.roles.map((role) {
            final isSelected = _controller.form.roles.contains(role.id);
            return UserGuideOptionCard(
              label: role.label,
              isSelected: isSelected,
              onTap: () => _controller.toggleRole(role.id),
              maxReached: _controller.form.roles.length >= 2 && !isSelected,
              icon: _getIconForRole(role.iconName),
            );
          }).toList() as List<Widget>,
        ),
      ],
    );
  }

  Widget _buildGoalsStep() {
    debugPrint('🟢 Rendering goals step');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What are you looking for?',
          style: AppTypography.h3.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 8),
        Text(
          'Select up to 3 options',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: UserGuideConstants.goals.map((goal) {
            final isSelected = _controller.form.goals.contains(goal.id);
            return UserGuideOptionCard(
              label: goal.label,
              isSelected: isSelected,
              onTap: () => _controller.toggleGoal(goal.id),
              maxReached: _controller.form.goals.length >= 3 && !isSelected,
              icon: _getIconForGoal(goal.iconName),
            );
          }).toList() as List<Widget>,
        ),
      ],
    );
  }

  Widget _buildSkillsStep() {
    debugPrint('🔵 Rendering skills step');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What are your specialisations & skills?',
          style: AppTypography.h3.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 20),
        Text(
          'Specialisations (up to 3)',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: UserGuideConstants.specialisations.map((spec) {
            final isSelected = _controller.form.specialisations.contains(spec);
            return UserGuideChip(
              label: spec,
              isSelected: isSelected,
              onTap: () => _controller.toggleSpecialisation(spec),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          'Top Skills (up to 6)',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: UserGuideConstants.skills.map((skill) {
            final isSelected = _controller.form.skills.contains(skill);
            return UserGuideChip(
              label: skill,
              isSelected: isSelected,
              onTap: () => _controller.toggleSkill(skill),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          'Availability',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: UserGuideConstants.availabilityOptions.map((option) {
            final isSelected = _controller.form.availability.contains(option);
            return UserGuideChip(
              label: option,
              isSelected: isSelected,
              onTap: () => _controller.toggleAvailability(option),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFinalTouchesStep() {
    debugPrint('🟣 Rendering final touches step');
    // Controllers are now managed in state to prevent cursor jumping/backward typing
    
    // Sync if needed (e.g. if updated from elsewhere, though unlikely here)
    if (_bioController.text != _controller.form.bio) {
      _bioController.value = _bioController.value.copyWith(
        text: _controller.form.bio,
        selection: TextSelection.collapsed(offset: _controller.form.bio.length),
      );
    }
    if (_countryController.text != (_controller.form.country ?? '')) {
      final newText = _controller.form.country ?? '';
      _countryController.value = _countryController.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Final touches',
          style: AppTypography.h3.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete your profile',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Bio (at least 40 characters)',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: 4,
          minLines: 4,
          textDirection: TextDirection.ltr,
          controller: _bioController,
          decoration: InputDecoration(
            hintText: 'Tell us about yourself...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Country',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          textDirection: TextDirection.ltr,
          controller: _countryController,
          decoration: InputDecoration(
            hintText: 'Enter your country',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
        if (_controller.form.country?.toLowerCase() == 'kenya') ...[
          const SizedBox(height: 24),
          Text(
            'County',
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _controller.form.county,
            items: UserGuideConstants.counties.map((county) {
              return DropdownMenuItem(
                value: county,
                child: Text(county),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                _controller.setCounty(value);
              }
            },
            decoration: InputDecoration(
              labelText: 'Select your county',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔵 UserGuidePage build - currentStep: ${_controller.currentStep}');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Guide',
              style: AppTypography.h3,
            ),
            const SizedBox(height: 2),
            Text(
              'Help Magna understand you better.',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/auth/register'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: UserGuideProgressBar(
                currentStep: _controller.currentStep,
                totalSteps: UserGuideController.totalSteps,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: _buildStepContent(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: UserGuideBottomBar(
        canGoBack: _controller.canGoBack,
        canGoNext: _controller.canGoNext,
        isLastStep: _controller.isOnLastStep,
        canComplete: _controller.canComplete,
        currentStep: _controller.currentStep,
        totalSteps: UserGuideController.totalSteps,
        onBack: _controller.previousStep,
        onNextOrComplete: _handleNextOrComplete,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';

import '../../../data/models/user_guide_constants.dart';
import '../user_guide_step_shell.dart';

class FinalTouchesStep extends StatelessWidget {
  final String bio;
  final String? country;
  final String? county;
  final void Function(String bio) onBioChanged;
  final void Function(String country) onCountryChanged;
  final void Function(String? county) onCountyChanged;
  final bool isBioValid;
  final bool isCountryValid;
  final bool isCountyValid;

  const FinalTouchesStep({
    super.key,
    required this.bio,
    required this.country,
    required this.county,
    required this.onBioChanged,
    required this.onCountryChanged,
    required this.onCountyChanged,
    required this.isBioValid,
    required this.isCountryValid,
    required this.isCountyValid,
  });

  bool get _isKenya => (country ?? '').toLowerCase() == 'kenya';

  @override
  Widget build(BuildContext context) {
    return UserGuideStepShell(
      title: 'Final touches',
      subtitle: 'Add a short bio and where you\'re based.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bio',
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: 4,
            minLines: 3,
            decoration: InputDecoration(
              hintText: 'Tell the community who you are, what you do, and what you\'re excited about.',
              errorText: isBioValid ? null : 'Bio is too short.',
            ),
            onChanged: onBioChanged,
          ),
          const SizedBox(height: 16),
          Text(
            'Country',
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Where are you based?',
              errorText: isCountryValid ? null : 'Country is required.',
            ),
            onChanged: onCountryChanged,
          ),
          const SizedBox(height: 16),
          if (_isKenya) ...[
            Text(
              'County',
              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: county != null && county!.isNotEmpty ? county : null,
              decoration: InputDecoration(
                hintText: 'Select your county',
                errorText: isCountyValid ? null : 'County is required for Kenya.',
              ),
              items: UserGuideConstants.kenyaCounties
                  .map(
                    (c) => DropdownMenuItem<String>(
                      value: c,
                      child: Text(c),
                    ),
                  )
                  .toList(),
              onChanged: onCountyChanged,
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'We\'ll use this to improve recommendations and opportunities around you.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}


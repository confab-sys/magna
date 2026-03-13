import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';

import '../user_guide_step_shell.dart';

class SkillsAndAvailabilityStep extends StatefulWidget {
  final List<String> selectedSpecialisations;
  final List<String> selectedSkills;
  final List<String> selectedAvailability;
  final List<String> recommendedSpecialisations;
  final List<String> recommendedSkills;
  final List<String> availabilityOptions;
  final void Function(String value) onSpecialisationToggled;
  final void Function(String value) onSkillToggled;
  final void Function(String value) onAvailabilityToggled;
  final void Function(String customSkill) onCustomSkillAdded;

  const SkillsAndAvailabilityStep({
    super.key,
    required this.selectedSpecialisations,
    required this.selectedSkills,
    required this.selectedAvailability,
    required this.recommendedSpecialisations,
    required this.recommendedSkills,
    required this.availabilityOptions,
    required this.onSpecialisationToggled,
    required this.onSkillToggled,
    required this.onAvailabilityToggled,
    required this.onCustomSkillAdded,
  });

  @override
  State<SkillsAndAvailabilityStep> createState() => _SkillsAndAvailabilityStepState();
}

class _SkillsAndAvailabilityStepState extends State<SkillsAndAvailabilityStep> {
  final _customSkillController = TextEditingController();

  @override
  void dispose() {
    _customSkillController.dispose();
    super.dispose();
  }

  void _submitCustomSkill() {
    final text = _customSkillController.text.trim();
    if (text.isEmpty) return;
    widget.onCustomSkillAdded(text);
    _customSkillController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return UserGuideStepShell(
      title: 'What do you specialise in?',
      subtitle: 'Tell us where you shine and when you\'re available.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specialisation (pick up to 3)',
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final spec in widget.recommendedSpecialisations)
                _ChoiceChip(
                  label: spec,
                  isSelected: widget.selectedSpecialisations.contains(spec),
                  onTap: () => widget.onSpecialisationToggled(spec),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Top skills (pick up to 6)',
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final skill in widget.recommendedSkills)
                _ChoiceChip(
                  label: skill,
                  isSelected: widget.selectedSkills.contains(skill),
                  onTap: () => widget.onSkillToggled(skill),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customSkillController,
                  decoration: const InputDecoration(
                    hintText: 'Add a custom skill',
                  ),
                  onSubmitted: (_) => _submitCustomSkill(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _submitCustomSkill,
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Availability',
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in widget.availabilityOptions)
                _ChoiceChip(
                  label: option,
                  isSelected: widget.selectedAvailability.contains(option),
                  onTap: () => widget.onAvailabilityToggled(option),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent;
    final borderColor = isSelected ? AppColors.primary : AppColors.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}


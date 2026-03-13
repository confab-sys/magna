import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'dart:typed_data';

import '../user_guide_step_shell.dart';

class ProfilePictureStep extends StatelessWidget {
  final XFile? image;
  final ValueChanged<XFile?> onImageSelected;

  const ProfilePictureStep({
    super.key,
    required this.image,
    required this.onImageSelected,
  });

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      onImageSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return UserGuideStepShell(
      title: 'Add a face to your profile',
      subtitle: 'Optional, but it helps people recognize and remember you.',
      child: Column(
        children: [
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                _ProfileAvatar(image: image),
                Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                    onPressed: () => _pickImage(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'You can skip this for now and add a photo later.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => onImageSelected(null),
            child: const Text('Remove photo'),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final XFile? image;

  const _ProfileAvatar({required this.image});

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return CircleAvatar(
        radius: 48,
        backgroundColor: AppColors.surface,
        child: Icon(
          Icons.person,
          size: 40,
          color: AppColors.textSecondary,
        ),
      );
    }

    return FutureBuilder<Uint8List>(
      future: image!.readAsBytes(),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        return CircleAvatar(
          radius: 48,
          backgroundColor: AppColors.surface,
          backgroundImage: bytes != null ? MemoryImage(bytes) : null,
          child: bytes == null
              ? Icon(
                  Icons.person,
                  size: 40,
                  color: AppColors.textSecondary,
                )
              : null,
        );
      },
    );
  }
}


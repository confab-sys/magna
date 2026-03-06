import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/spacing.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class JobBannerPicker extends StatefulWidget {
  final Function(XFile?) onImageSelected;
  final XFile? initialImage;

  const JobBannerPicker({
    super.key,
    required this.onImageSelected,
    this.initialImage,
  });

  @override
  State<JobBannerPicker> createState() => _JobBannerPickerState();
}

class _JobBannerPickerState extends State<JobBannerPicker> {
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _image = widget.initialImage;
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final pickedFile = XFile(result.files.single.path!);
        setState(() {
          _image = pickedFile;
        });
        widget.onImageSelected(_image);
      } else if (result != null && result.files.single.bytes != null) {
        final pickedFile = XFile.fromData(
          result.files.single.bytes!,
          name: result.files.single.name,
        );
        setState(() {
          _image = pickedFile;
        });
        widget.onImageSelected(_image);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _removeImage() {
    setState(() {
      _image = null;
    });
    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: _image != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? Image.network(
                            _image!.path,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(_image!.path),
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: _removeImage,
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIcons.image(),
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Add Job Banner',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

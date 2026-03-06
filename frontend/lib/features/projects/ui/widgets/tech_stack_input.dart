import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/spacing.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TechStackInput extends StatefulWidget {
  final List<String> initialTags;
  final Function(List<String>) onChanged;

  const TechStackInput({
    super.key,
    required this.initialTags,
    required this.onChanged,
  });

  @override
  State<TechStackInput> createState() => _TechStackInputState();
}

class _TechStackInputState extends State<TechStackInput> {
  final TextEditingController _controller = TextEditingController();
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
  }

  void _addTag() {
    final tag = _controller.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _controller.clear();
      });
      widget.onChanged(_tags);
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Add technology (e.g. Flutter, Node.js)',
                ),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              onPressed: _addTag,
              icon: Icon(
                PhosphorIcons.plusCircle(),
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _tags.map((tag) {
            return Chip(
              label: Text(tag),
              onDeleted: () => _removeTag(tag),
              backgroundColor: AppColors.surface,
              deleteIcon: const Icon(Icons.close, size: 16),
            );
          }).toList(),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/shared/widgets/app_text_field.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MessageInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onAttach;

  const MessageInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.onAttach,
  });

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _canSend = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    final next = widget.controller.text.trim().isNotEmpty;
    if (next != _canSend) {
      setState(() {
        _canSend = next;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              onPressed: widget.onAttach,
              icon: PhosphorIcon(
                PhosphorIcons.paperclip(),
                size: 22,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppTextField(
                controller: widget.controller,
                label: 'Message',
                maxLines: 4,
                minLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _canSend ? widget.onSend : null,
              icon: PhosphorIcon(
                PhosphorIcons.paperPlaneRight(),
                size: 22,
                color: _canSend ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



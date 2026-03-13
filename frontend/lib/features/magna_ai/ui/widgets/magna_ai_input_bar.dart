import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MagnaAiInputBar extends StatefulWidget {
  final Function(String) onSend;
  final bool isSending;
  final String? initialText;

  const MagnaAiInputBar({
    super.key,
    required this.onSend,
    this.isSending = false,
    this.initialText,
  });

  @override
  State<MagnaAiInputBar> createState() => _MagnaAiInputBarState();
}

class _MagnaAiInputBarState extends State<MagnaAiInputBar> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _controller.addListener(_onTextChanged);
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _hasText = true;
    }
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (!_hasText || widget.isSending) return;
    widget.onSend(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(PhosphorIcons.plus(), color: AppColors.textSecondary),
            onPressed: () {}, // TODO: Attachments
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 5,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Message Magna AI...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                textInputAction: TextInputAction.newline, // Allow multiline
              ),
            ),
          ),
          const SizedBox(width: 8),
          widget.isSending
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    _hasText ? PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.fill) : PhosphorIcons.microphone(),
                    color: _hasText ? AppColors.primary : AppColors.textSecondary,
                  ),
                  onPressed: _hasText ? _handleSend : () {}, // TODO: Voice
                ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final String? errorText;
  final bool autocorrect;
  final bool enableSuggestions;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines,
    this.minLines,
    this.errorText,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMaxLines = obscureText ? 1 : (maxLines ?? 1);
    final effectiveMinLines = obscureText ? 1 : minLines;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      maxLines: effectiveMaxLines,
      minLines: effectiveMinLines,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        errorText: errorText,
      ),
    );
  }
}

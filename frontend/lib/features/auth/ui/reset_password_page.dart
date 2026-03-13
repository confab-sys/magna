import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/auth/ui/controllers/reset_password_controller.dart';
import 'package:magna_coders/shared/widgets/app_text_field.dart';
import 'package:magna_coders/shared/widgets/primary_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;

  const ResetPasswordPage({
    super.key,
    required this.token,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late final ResetPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ResetPasswordController(token: widget.token)
      ..addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _onSubmit() async {
    final ok = await _controller.submit();
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successful. Please sign in.')),
      );
      context.go('/login');
    } else {
      final msg = _controller.formError ?? 'Reset failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.token.trim().isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('Reset password'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'This reset link is missing a token. Please request a new one.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Reset password'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: PhosphorIcon(
            PhosphorIcons.arrowLeft(),
            color: AppColors.textSecondary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create a new password', style: AppTypography.h3),
            const SizedBox(height: 8),
            Text(
              'Your new password must be at least 8 characters.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            AppTextField(
              controller: _controller.newPasswordController,
              label: 'New password',
              obscureText: !_controller.showNewPassword,
              autocorrect: false,
              enableSuggestions: false,
              errorText: _controller.newPasswordError,
              suffixIcon: IconButton(
                onPressed: _controller.toggleNewPasswordVisibility,
                icon: PhosphorIcon(
                  _controller.showNewPassword
                      ? PhosphorIcons.eyeSlash()
                      : PhosphorIcons.eye(),
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _controller.confirmPasswordController,
              label: 'Confirm new password',
              obscureText: !_controller.showConfirmPassword,
              autocorrect: false,
              enableSuggestions: false,
              errorText: _controller.confirmPasswordError,
              suffixIcon: IconButton(
                onPressed: _controller.toggleConfirmPasswordVisibility,
                icon: PhosphorIcon(
                  _controller.showConfirmPassword
                      ? PhosphorIcons.eyeSlash()
                      : PhosphorIcons.eye(),
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Reset password',
              onPressed: _controller.loading ? null : _onSubmit,
              loading: _controller.loading,
            ),
          ],
        ),
      ),
    );
  }
}


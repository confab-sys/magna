import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/auth/ui/controllers/forgot_password_controller.dart';
import 'package:magna_coders/shared/widgets/app_text_field.dart';
import 'package:magna_coders/shared/widgets/primary_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final ForgotPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ForgotPasswordController()..addListener(_onStateChanged);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Forgot password'),
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
        child: _controller.sent
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Check your email', style: AppTypography.h3),
                  const SizedBox(height: 8),
                  Text(
                    'If an account exists for this email, a reset link has been sent.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    label: 'Back to login',
                    onPressed: () => context.go('/login'),
                    loading: false,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reset your password', style: AppTypography.h3),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your email and we\'ll send you a secure reset link.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    controller: _controller.emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    errorText: _controller.emailError,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Send reset link',
                    onPressed: _controller.loading ? null : _controller.submit,
                    loading: _controller.loading,
                  ),
                ],
              ),
      ),
    );
  }
}


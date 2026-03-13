import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/auth/ui/controllers/register_controller.dart';
import 'package:magna_coders/features/auth/ui/widgets/social_auth_button.dart';
import 'package:magna_coders/shared/widgets/primary_button.dart';
import 'package:magna_coders/shared/widgets/app_text_field.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final RegisterController _controller;

  Future<void> _onRegister() async {
    final ok = await _controller.submit();
    if (!mounted) return;
    if (ok) {
      context.go('/user-guide');
    } else {
      final msg = _controller.formError ?? 'Registration failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = RegisterController()..addListener(_onStateChanged);
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
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: PhosphorIcon(
                      PhosphorIcons.arrowLeft(),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Create account', style: AppTypography.h3),
              const SizedBox(height: 6),
              Text(
                'Join Magna and start building.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              _DividerWithText(
                text: 'continue with username',
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _controller.usernameController,
                label: 'Username',
                textInputAction: TextInputAction.next,
                autocorrect: false,
                enableSuggestions: false,
                errorText: _controller.usernameError,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _controller.emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                enableSuggestions: false,
                errorText: _controller.emailError,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _controller.passwordController,
                label: 'Password',
                obscureText: !_controller.showPassword,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                enableSuggestions: false,
                errorText: _controller.passwordError,
                suffixIcon: IconButton(
                  onPressed: _controller.togglePasswordVisibility,
                  icon: PhosphorIcon(
                    _controller.showPassword
                        ? PhosphorIcons.eyeSlash()
                        : PhosphorIcons.eye(),
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _controller.confirmPasswordController,
                label: 'Confirm password',
                obscureText: !_controller.showConfirmPassword,
                textInputAction: TextInputAction.done,
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
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'Create account',
                onPressed: _controller.loading ? null : _onRegister,
                loading: _controller.loading,
              ),
              const SizedBox(height: 18),
              _DividerWithText(
                text: 'or continue with',
              ),
              const SizedBox(height: 18),
              SocialAuthButton(
                label: 'Continue with Google',
                icon: PhosphorIcons.googleLogo(),
                onPressed: _controller.loading
                    ? null
                    : () async {
                        try {
                          await _controller.startGoogle();
                        } catch (_) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not start Google sign-in')),
                          );
                        }
                      },
              ),
              const SizedBox(height: 10),
              SocialAuthButton(
                label: 'Continue with GitHub',
                icon: PhosphorIcons.githubLogo(),
                onPressed: _controller.loading
                    ? null
                    : () async {
                        try {
                          await _controller.startGithub();
                        } catch (_) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not start GitHub sign-in')),
                          );
                        }
                      },
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Sign in'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DividerWithText extends StatelessWidget {
  final String text;

  const _DividerWithText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: AppColors.border.withOpacity(0.8)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: AppColors.border.withOpacity(0.8)),
        ),
      ],
    );
  }
}

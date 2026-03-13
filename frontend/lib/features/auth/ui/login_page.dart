import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/auth/ui/controllers/login_controller.dart';
import 'package:magna_coders/features/auth/ui/widgets/social_auth_button.dart';
import 'package:magna_coders/shared/widgets/primary_button.dart';
import 'package:magna_coders/shared/widgets/app_text_field.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController _controller;

  Future<void> _onLogin() async {
    final ok = await _controller.submit();
    if (!mounted) return;
    if (ok) {
      context.go('/feed');
    } else {
      final msg = _controller.formError ?? 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = LoginController()..addListener(_onStateChanged);
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
              const SizedBox(height: 8),
              Text('Welcome back', style: AppTypography.h3),
              const SizedBox(height: 6),
              Text(
                'Sign in to continue to Magna',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              _DividerWithText(text: 'continue with email'),
              const SizedBox(height: 18),
              AppTextField(
                controller: _controller.emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                errorText: _controller.emailError,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _controller.passwordController,
                label: 'Password',
                obscureText: !_controller.showPassword,
                textInputAction: TextInputAction.done,
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Login',
                onPressed: _controller.loading ? null : _onLogin,
                loading: _controller.loading,
              ),
              const SizedBox(height: 18),
              _DividerWithText(text: 'or continue with'),
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
                            const SnackBar(
                              content: Text('Could not start Google sign-in'),
                            ),
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
                            const SnackBar(
                              content: Text('Could not start GitHub sign-in'),
                            ),
                          );
                        }
                      },
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don’t have an account?',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text('Create account'),
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
        Expanded(child: Divider(color: AppColors.border.withOpacity(0.8))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border.withOpacity(0.8))),
      ],
    );
  }
}

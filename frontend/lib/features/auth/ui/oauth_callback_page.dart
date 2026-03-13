import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/core/auth/auth_service.dart';

class OAuthCallbackPage extends StatefulWidget {
  final Uri callbackUri;

  const OAuthCallbackPage({
    super.key,
    required this.callbackUri,
  });

  @override
  State<OAuthCallbackPage> createState() => _OAuthCallbackPageState();
}

class _OAuthCallbackPageState extends State<OAuthCallbackPage> {
  final _auth = AuthService();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _handle();
  }

  Future<void> _handle() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ok = await _auth.handleOAuthCallback(widget.callbackUri);
      if (!mounted) return;
      if (ok) {
        context.go('/user-guide');
        return;
      }
      setState(() {
        _error = 'OAuth sign-in failed. Please try again.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'OAuth sign-in failed. Please try again.';
      });
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Signing you in…', style: AppTypography.h3),
              const SizedBox(height: 8),
              if (_loading)
                const CircularProgressIndicator()
              else if (_error != null) ...[
                Text(
                  _error!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _handle,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

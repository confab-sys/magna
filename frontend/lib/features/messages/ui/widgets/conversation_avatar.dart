import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'online_status_dot.dart';

class ConversationAvatar extends StatelessWidget {
  final String? name;
  final String? avatarUrl;
  final bool isOnline;
  final double size;

  const ConversationAvatar({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.isOnline,
    this.size = 44,
  });

  String get _initial {
    final source = (name ?? '').trim();
    if (source.isNotEmpty) {
      return source.characters.first.toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final radius = size / 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(-0.3, -0.3),
              radius: 1,
              colors: [
                AppColors.surface,
                Color(0xFF101010),
              ],
            ),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: ClipOval(
            child: avatarUrl != null
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Text(
                      _initial,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
          ),
        ),
        Positioned(
          right: -1,
          bottom: -1,
          child: OnlineStatusDot(
            isOnline: isOnline,
            size: 9,
          ),
        ),
      ],
    );
  }
}


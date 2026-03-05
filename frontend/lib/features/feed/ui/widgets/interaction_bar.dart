import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/spacing.dart';

class InteractionBar extends StatelessWidget {
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const InteractionBar({
    super.key,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _InteractionButton(
                icon: isLiked ? PhosphorIcons.heart(PhosphorIconsStyle.fill) : PhosphorIcons.heart(),
                label: likesCount.toString(),
                color: isLiked ? AppColors.primary : AppColors.textSecondary,
                onTap: onLike,
              ),
              const SizedBox(width: AppSpacing.md),
              _InteractionButton(
                icon: PhosphorIcons.chatCircle(),
                label: commentsCount.toString(),
                color: AppColors.textSecondary,
                onTap: onComment,
              ),
            ],
          ),
          IconButton(
            icon: PhosphorIcon(PhosphorIcons.shareNetwork(), color: AppColors.textSecondary),
            onPressed: onShare,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final PhosphorIconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _InteractionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            PhosphorIcon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

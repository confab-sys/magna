import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ConversationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final String? avatarUrl;
  final VoidCallback? onBack;
  final VoidCallback? onMore;

  const ConversationAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.avatarUrl,
    this.onBack,
    this.onMore,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: PhosphorIcon(PhosphorIcons.arrowLeft()),
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Text(
                    title.isNotEmpty ? title[0].toUpperCase() : '?',
                    style: AppTypography.bodyMedium,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: PhosphorIcon(PhosphorIcons.dotsThreeVertical()),
          onPressed: onMore,
        ),
      ],
    );
  }
}


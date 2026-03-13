import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/magna_ai/domain/entities/ai_conversation_entity.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class MagnaAiConversationPanel extends StatelessWidget {
  final List<AIConversationEntity> conversations;
  final String? activeId;
  final Function(String) onSelect;
  final VoidCallback onNewChat;

  const MagnaAiConversationPanel({
    super.key,
    required this.conversations,
    required this.activeId,
    required this.onSelect,
    required this.onNewChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280, // Fixed width for desktop/tablet, or flexible
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onNewChat,
                icon: Icon(PhosphorIcons.plus(), size: 18),
                label: const Text('New Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          Expanded(
            child: conversations.isEmpty
                ? Center(
                    child: Text(
                      'No conversations yet',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conv = conversations[index];
                      final isActive = conv.id == activeId;
                      return ListTile(
                        selected: isActive,
                        selectedTileColor: AppColors.primary.withOpacity(0.1),
                        leading: Icon(
                          PhosphorIcons.chatCircleText(),
                          color: isActive ? AppColors.primary : AppColors.textSecondary,
                        ),
                        title: Text(
                          conv.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                            color: isActive ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          timeago.format(conv.updatedAt),
                          style: AppTypography.caption.copyWith(fontSize: 10),
                        ),
                        onTap: () => onSelect(conv.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

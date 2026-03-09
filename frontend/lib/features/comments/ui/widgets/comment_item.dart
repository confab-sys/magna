import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/comments/data/comments_repository.dart';
import 'package:magna_coders/features/comments/domain/comment.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentItem extends StatefulWidget {
  final Comment comment;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;
  final bool isReply;
  final String? currentUserId;

  const CommentItem({
    super.key,
    required this.comment,
    this.onReply,
    this.onDelete,
    this.isReply = false,
    this.currentUserId,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  late bool _isLiked;
  late int _likesCount;
  final _repository = CommentsRepository();

  @override
  void initState() {
    super.initState();
    _isLiked = widget.comment.isLiked;
    _likesCount = widget.comment.likesCount;
  }

  @override
  void didUpdateWidget(CommentItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.comment.id == widget.comment.id) {
      _isLiked = widget.comment.isLiked;
      _likesCount = widget.comment.likesCount;
    }
  }

  Future<void> _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });

    final success = await _repository.toggleLike(widget.comment.id);
    if (!success && mounted) {
      setState(() {
        _isLiked = !_isLiked;
        _likesCount = (_likesCount + (_isLiked ? 1 : -1)).clamp(0, 1 << 30);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: widget.isReply ? 12 : 16,
            backgroundImage: widget.comment.authorAvatar != null
                ? NetworkImage(widget.comment.authorAvatar!)
                : null,
            child: widget.comment.authorAvatar == null
                ? Text(
                    widget.comment.authorName[0].toUpperCase(),
                    style: TextStyle(fontSize: widget.isReply ? 10 : 14),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.comment.authorName,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(widget.comment.createdAt),
                      style: AppTypography.caption,
                    ),
                    // Debug print to check IDs if needed
                    // Text('${widget.currentUserId} vs ${widget.comment.authorId}', style: TextStyle(fontSize: 8)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.comment.content,
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: _toggleLike,
                      child: Row(
                        children: [
                          Icon(
                            _isLiked
                                ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                                : PhosphorIcons.heart(),
                            size: 16,
                            color: _isLiked ? Colors.red : AppColors.textSecondary,
                          ),
                          if (_likesCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              _likesCount.toString(),
                              style: AppTypography.caption,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    InkWell(
                      onTap: widget.onReply,
                      child: Text(
                        'Reply',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (widget.onDelete != null) ...[
                        const SizedBox(width: 24),
                        // Only show delete if current user owns the comment
                        // Fallback: if currentUserId is null (loading/error), hide it.
                        if (widget.currentUserId != null && 
                            widget.currentUserId == widget.comment.authorId)
                          InkWell(
                          onTap: widget.onDelete,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              PhosphorIcons.trash(),
                              size: 16,
                              color: Colors.red[400],
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

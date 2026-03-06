import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/spacing.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/feed/domain/post.dart';
import 'package:magna_coders/features/feed/data/feed_repository.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class FeedPostCard extends StatefulWidget {
  final Post post;
  final Function(Post)? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onOpenPost;
  final bool isDetailView;

  const FeedPostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onOpenPost,
    this.isDetailView = false,
  });

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  late bool _isLiked;
  late int _likeCount;
  late int _commentCount;
  final _repository = FeedRepository();

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likeCount = widget.post.likeCount;
    _commentCount = widget.post.commentCount;
  }

  @override
  void didUpdateWidget(FeedPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update from widget if it's a different post
    if (oldWidget.post.id != widget.post.id) {
      _isLiked = widget.post.isLiked;
      _likeCount = widget.post.likeCount;
      _commentCount = widget.post.commentCount;
      return;
    }

    if (widget.post.isLiked && !_isLiked) {
      _isLiked = true;
    }

    if (widget.post.likeCount != _likeCount) {
      if (!_isLiked || widget.post.likeCount >= _likeCount) {
        _likeCount = widget.post.likeCount;
      }
    }

    if (widget.post.commentCount != _commentCount) {
      _commentCount = widget.post.commentCount;
    }
  }

  Future<void> _handleLike() async {
    if (_isLiked) return; // Prevent unliking, "once liked, stays liked"

    // Optimistic update
    setState(() {
      _isLiked = true;
      _likeCount += 1;
    });

    try {
      final success = await _repository.likePost(widget.post.id);
      if (!success) {
        // Revert if failed
        if (mounted) {
          setState(() {
            _isLiked = false;
            _likeCount -= 1;
          });
        }
      } else if (widget.onLike != null) {
        widget.onLike!(widget.post.copyWith(
          isLiked: _isLiked,
          likeCount: _likeCount,
        ));
      }
    } catch (e) {
      debugPrint('Error liking post: $e');
      if (mounted) {
        setState(() {
          _isLiked = false;
          _likeCount -= 1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row
          _buildHeader(context),
          
          const SizedBox(height: AppSpacing.sm),
          
          // 2. Post Text
          _buildPostText(context),
          
          // 3. Image Section (Optional)
          if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _buildImage(context),
          ],
          
          const SizedBox(height: AppSpacing.md),
          
          // 4. Interaction Bar
          _buildInteractionBar(context),
        ],
      ),
    );

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: widget.isDetailView
          ? content
          : InkWell(
              onTap: widget.onOpenPost,
              borderRadius: BorderRadius.circular(16),
              child: content,
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.secondary,
              backgroundImage: widget.post.authorAvatar != null && widget.post.authorAvatar!.isNotEmpty
                  ? NetworkImage(widget.post.authorAvatar!)
                  : null,
              child: widget.post.authorAvatar == null || widget.post.authorAvatar!.isEmpty
                  ? Text(
                      (widget.post.authorName ?? 'A')[0].toUpperCase(),
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            
            // Author Info Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.authorName ?? 'Unknown',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatTimestamp(widget.post.createdAt),
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ],
        ),
        
        // Post Button (Right Side)
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Post',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.post.title,
          style: AppTypography.h3.copyWith(
            fontSize: 18, // Slightly larger than standard body
          ),
        ),
        if (widget.post.content != null && widget.post.content!.isNotEmpty) ...[
          const SizedBox(height: 4), // Small spacing between title and content
          Text(
            widget.post.content!,
            style: AppTypography.bodyMedium,
            maxLines: widget.isDetailView ? null : 3,
            overflow: widget.isDetailView ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        widget.post.imageUrl!,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 220,
            width: double.infinity,
            color: AppColors.background,
            child: const Center(
              child: Icon(Icons.broken_image, color: AppColors.textSecondary),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInteractionBar(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: _handleLike,
          child: _buildInteractionItem(
            icon: _isLiked ? PhosphorIcons.heart(PhosphorIconsStyle.fill) : PhosphorIcons.heart(),
            label: _likeCount.toString(),
            color: _isLiked ? Colors.red : null,
          ),
        ),
        const SizedBox(width: 24),
        InkWell(
          onTap: widget.onComment,
          child: _buildInteractionItem(
            icon: PhosphorIcons.chatCircle(),
            label: _commentCount.toString(),
          ),
        ),
        const SizedBox(width: 24),
        InkWell(
          onTap: widget.onShare,
          child: _buildInteractionItem(
            icon: PhosphorIcons.shareNetwork(),
            label: 'Share',
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionItem({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: color ?? AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: color ?? AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

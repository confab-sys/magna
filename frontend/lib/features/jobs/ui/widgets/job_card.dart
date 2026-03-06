import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/spacing.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/jobs/data/jobs_repository.dart';
import 'package:magna_coders/features/jobs/domain/job.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class JobCard extends StatefulWidget {
  final Job job;
  final VoidCallback? onApply;
  final VoidCallback? onViewJob;
  final Function(Job)? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final bool isDetailView;

  const JobCard({
    super.key,
    required this.job,
    this.onApply,
    this.onViewJob,
    this.onLike,
    this.onComment,
    this.onShare,
    this.isDetailView = false,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  final _repository = JobsRepository();
  late bool _isLiked;
  late int _likeCount;
  late int _commentCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.job.isLiked;
    _likeCount = widget.job.likesCount;
    _commentCount = widget.job.commentsCount;
  }

  @override
  void didUpdateWidget(JobCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update from widget if the new data is "more liked" or if it's a different job
    if (oldWidget.job.id != widget.job.id) {
      _isLiked = widget.job.isLiked;
      _likeCount = widget.job.likesCount;
      _commentCount = widget.job.commentsCount;
      return;
    }

    if (widget.job.isLiked && !_isLiked) {
      _isLiked = true;
    }
    
    // Only update count if it's different and we are not in a local "liked" state that is ahead of the widget
    if (widget.job.likesCount != _likeCount) {
      // If we locally liked it, don't let the widget set it back to a lower number unless it's a significant change
      if (!_isLiked || widget.job.likesCount >= _likeCount) {
        _likeCount = widget.job.likesCount;
      }
    }
    
    if (widget.job.commentsCount != _commentCount) {
      _commentCount = widget.job.commentsCount;
    }
  }

  Future<void> _toggleLike() async {
    if (_isLiked) return; // Prevent unliking, "once liked, stays liked"

    setState(() {
      _isLiked = true;
      _likeCount += 1;
    });

    final success = await _repository.likeJob(widget.job.id);

    if (!success && mounted) {
      setState(() {
        _isLiked = false;
        _likeCount -= 1;
      });
    } else if (widget.onLike != null) {
      widget.onLike!(widget.job.copyWith(
        isLiked: _isLiked,
        likesCount: _likeCount,
      ));
    }
  }

  void _onCommentPressed() {
    if (widget.onComment != null) {
      widget.onComment!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER ROW
          _buildHeader(),
          const SizedBox(height: AppSpacing.md),

          // 2. JOB IMAGE BANNER
          if (widget.job.jobImageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.job.jobImageUrl!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: AppColors.background,
                    alignment: Alignment.center,
                    child: Icon(PhosphorIcons.imageBroken(), color: AppColors.textSecondary),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // 3. JOB TITLE
          Text(
            widget.job.title,
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // 4. JOB DESCRIPTION
          Text(
            widget.job.description,
            maxLines: widget.isDetailView ? null : 2,
            overflow: widget.isDetailView ? TextOverflow.visible : TextOverflow.ellipsis,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 5. KEY INFORMATION ROW
          _buildKeyInfo(),
          const SizedBox(height: AppSpacing.md),

          // 6. ACTION BUTTON ROW
          _buildActionButtons(),
          const SizedBox(height: AppSpacing.xl),

          // 7. ENGAGEMENT BAR
          _buildEngagementBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Company Avatar
            CircleAvatar(
              radius: 20,
              backgroundImage: widget.job.companyLogoUrl != null
                  ? NetworkImage(widget.job.companyLogoUrl!)
                  : null,
              backgroundColor: AppColors.primary,
              child: widget.job.companyLogoUrl == null
                  ? Text(
                      widget.job.companyName.isNotEmpty
                          ? widget.job.companyName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            
            // Company Info Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.job.companyName,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.job.companyVerified) ...[
                      const SizedBox(width: 4),
                      Icon(
                        PhosphorIcons.sealCheck(PhosphorIconsStyle.fill),
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
                Text(
                  timeago.format(widget.job.createdAt),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        
        // Job Type Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            widget.job.jobType.toUpperCase(),
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyInfo() {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        _buildInfoItem(PhosphorIcons.mapPin(), widget.job.location),
        if (widget.job.salary != null)
          _buildInfoItem(PhosphorIcons.money(), widget.job.salary!),
        if (widget.job.deadline != null)
          _buildInfoItem(
            PhosphorIcons.clock(), 
            'Closes ${timeago.format(widget.job.deadline!, allowFromNow: true)}'
          ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: widget.onApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Apply Now'),
          ),
        ),
        if (!widget.isDetailView) ...[
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onViewJob,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('View Details'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEngagementBar() {
    return Row(
      children: [
        InkWell(
          onTap: _toggleLike,
          child: _buildEngagementItem(
            _isLiked ? PhosphorIcons.heart(PhosphorIconsStyle.fill) : PhosphorIcons.heart(),
            _likeCount.toString(),
            color: _isLiked ? Colors.red : null,
          ),
        ),
        const SizedBox(width: 24),
        InkWell(
          onTap: _onCommentPressed,
          child: _buildEngagementItem(
            PhosphorIcons.chatCircle(),
            _commentCount.toString(),
          ),
        ),
        const SizedBox(width: 24),
        InkWell(
          onTap: widget.onShare,
          child: _buildEngagementItem(PhosphorIcons.shareNetwork(), "Share"),
        ),
      ],
    );
  }

  Widget _buildEngagementItem(IconData icon, String label, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
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
}

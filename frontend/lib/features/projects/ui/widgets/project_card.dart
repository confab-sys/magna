import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/spacing.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/projects/data/projects_repository.dart';
import 'package:magna_coders/features/projects/domain/project.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProjectCard extends StatefulWidget {
  final Project project;
  final VoidCallback? onViewDetails;
  final Function(Project)? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final bool isDetailView;

  const ProjectCard({
    super.key,
    required this.project,
    this.onViewDetails,
    this.onLike,
    this.onComment,
    this.onShare,
    this.isDetailView = false,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  final _repository = ProjectsRepository();
  late bool _isLiked;
  late int _likeCount;
  late int _commentCount;
  bool _requestSent = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.project.isLiked;
    _likeCount = widget.project.likesCount;
    _commentCount = widget.project.commentsCount;
  }

  @override
  void didUpdateWidget(ProjectCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update from widget if it's a different project or if the widget's liked state changed
    if (oldWidget.project.id != widget.project.id) {
      _isLiked = widget.project.isLiked;
      _likeCount = widget.project.likesCount;
      _commentCount = widget.project.commentsCount;
      return;
    }

    if (widget.project.isLiked && !_isLiked) {
      _isLiked = true;
    }

    if (widget.project.likesCount != _likeCount) {
      if (!_isLiked || widget.project.likesCount >= _likeCount) {
        _likeCount = widget.project.likesCount;
      }
    }

    if (widget.project.commentsCount != _commentCount) {
      _commentCount = widget.project.commentsCount;
    }
  }

  Future<void> _toggleLike() async {
    if (_isLiked) return; // Prevent unliking, "once liked, stays liked"

    setState(() {
      _isLiked = true;
      _likeCount += 1;
    });

    final success = await _repository.likeProject(widget.project.id);

    if (!success && mounted) {
      setState(() {
        _isLiked = false;
        _likeCount -= 1;
      });
    } else if (widget.onLike != null) {
      widget.onLike!(widget.project.copyWith(
        isLiked: _isLiked,
        likesCount: _likeCount,
      ));
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

          // Project Image
          if (widget.project.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.project.imageUrl!,
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

          // 3. TITLE & DESCRIPTION
          Text(
            widget.project.title,
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.isDetailView ? widget.project.shortDescription : widget.project.shortDescription, // Assuming shortDescription is full for now or use description if available
            maxLines: widget.isDetailView ? null : 3,
            overflow: widget.isDetailView ? TextOverflow.visible : TextOverflow.ellipsis,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 4. TECH STACK
          _buildTechStack(),
          const SizedBox(height: AppSpacing.md),

          // Project Timeline
          _buildProjectMeta(),

          // 5. CONTRIBUTOR NEEDS
          if (widget.project.lookingForContributors) ...[
            _buildContributorNeeds(),
            const SizedBox(height: AppSpacing.md),
          ],

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
            CircleAvatar(
              radius: 20,
              backgroundImage: widget.project.ownerAvatarUrl != null
                  ? NetworkImage(widget.project.ownerAvatarUrl!)
                  : null,
              backgroundColor: AppColors.primary,
              child: widget.project.ownerAvatarUrl == null
                  ? Text(
                      widget.project.ownerName.isNotEmpty
                          ? widget.project.ownerName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.project.ownerName,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatTimestamp(widget.project.createdAt),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        _buildStatusPill(),
      ],
    );
  }

  Widget _buildStatusPill() {
    Color pillColor;
    switch (widget.project.status.toUpperCase()) {
      case 'OPEN':
        pillColor = AppColors.success;
        break;
      case 'IN PROGRESS':
        pillColor = AppColors.warning;
        break;
      case 'COMPLETED':
        pillColor = AppColors.primary;
        break;
      default:
        pillColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: pillColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pillColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        widget.project.status.toUpperCase(),
        style: AppTypography.bodySmall.copyWith(
          color: pillColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildTechStack() {
    final displayStack = widget.project.techStack.take(4).toList();
    final remainingCount = widget.project.techStack.length - 4;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        ...displayStack.map((tech) => Chip(
              label: Text(
                tech,
                style: AppTypography.bodySmall,
              ),
              backgroundColor: AppColors.background,
              side: BorderSide.none,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            )),
        if (remainingCount > 0)
          Chip(
            label: Text(
              '+$remainingCount',
              style: AppTypography.bodySmall,
            ),
            backgroundColor: AppColors.background,
            side: BorderSide.none,
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  Widget _buildProjectMeta() {
    if (widget.project.startDate == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(PhosphorIcons.calendar(), size: 16, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${DateFormat('MMM yyyy').format(widget.project.startDate!)}${widget.project.endDate != null ? ' - ${DateFormat('MMM yyyy').format(widget.project.endDate!)}' : ' - Present'}',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildContributorNeeds() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.usersThree(PhosphorIconsStyle.fill), size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Looking for Contributors ${widget.project.maxContributors != null ? '(${widget.project.maxContributors} max)' : ''}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: _requestSent
              ? null
              : () {
                  setState(() {
                    _requestSent = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request sent, awaiting aproval')),
                  );
                },
          style: _requestSent
              ? ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textSecondary,
                  elevation: 0,
                  side: BorderSide(color: AppColors.border),
                )
              : null,
          child: Text(_requestSent ? "Request sent" : "Join Project"),
        ),
        Row(
          children: [
            if (widget.project.repositoryUrl != null)
              IconButton(
                icon: Icon(PhosphorIcons.githubLogo()),
                onPressed: () => _launchUrl(widget.project.repositoryUrl!),
                tooltip: 'Repository',
              ),
            if (widget.project.liveDemoUrl != null) ...[
              const SizedBox(width: AppSpacing.md),
              IconButton(
                icon: Icon(PhosphorIcons.arrowSquareOut()),
                onPressed: () => _launchUrl(widget.project.liveDemoUrl!),
                tooltip: 'Live Demo',
              ),
            ],
          ],
        ),
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
          onTap: widget.onComment,
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
        const Spacer(),
        InkWell(
          onTap: () {
            setState(() {
              _isSaved = !_isSaved;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_isSaved ? 'Project saved' : 'Project unsaved')),
            );
          },
          child: _buildEngagementItem(
            _isSaved ? PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.fill) : PhosphorIcons.bookmarkSimple(),
            _isSaved ? 'Saved' : 'Save',
            color: _isSaved ? AppColors.primary : null,
          ),
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

  String _formatTimestamp(DateTime timestamp) {
    return timeago.format(timestamp);
  }
}

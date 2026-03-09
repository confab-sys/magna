import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/spacing.dart';
import 'package:magna_coders/core/auth/token_storage.dart';
import 'package:magna_coders/features/comments/data/comments_repository.dart';
import 'package:magna_coders/features/comments/domain/comment.dart';
import 'package:magna_coders/features/comments/ui/widgets/comment_item.dart';
import 'package:magna_coders/shared/widgets/app_loader.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CommentsSheet extends StatefulWidget {
  final String postId;
  final bool isJob;
  final bool isProject;

  const CommentsSheet({
    super.key,
    required this.postId,
    this.isJob = false,
    this.isProject = false,
  });

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _repository = CommentsRepository();
  final _controller = TextEditingController();
  List<Comment> _comments = [];
  bool _loading = true;
  String? _replyToId;
  String? _replyToUser;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadComments();
  }

  Future<void> _loadUser() async {
    final userId = await TokenStorage.readUserId();
    if (mounted) {
      setState(() => _currentUserId = userId);
    }
  }

  Future<void> _loadComments() async {
    setState(() => _loading = true);
    debugPrint('Loading comments for postId: ${widget.postId}');
    try {
      final comments = await _repository.getComments(widget.postId);
      debugPrint('Loaded ${comments.length} comments');
      if (mounted) {
        setState(() {
          _comments = comments;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading comments in sheet: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _addComment() async {
    if (_controller.text.trim().isEmpty) return;

    final content = _controller.text;
    _controller.clear();
    
    // Optimistic UI update could be added here
    
    final newComment = await _repository.addComment(
      widget.postId,
      content,
      parentId: _replyToId,
      isJob: widget.isJob,
      isProject: widget.isProject,
    );

    if (newComment != null && mounted) {
      setState(() {
        _comments.add(newComment); // Add to list, sorting will handle it
        _replyToId = null;
        _replyToUser = null;
      });
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _deleteComment(String id) async {
    final success = await _repository.deleteComment(id);
    if (success && mounted) {
      setState(() {
        _comments.removeWhere((c) => c.id == id);
      });
    }
  }

  // Organize comments into parent-child structure
  List<Comment> _getSortedComments() {
    // 1. Get all root comments (no parent_id)
    final rootComments = _comments.where((c) => c.parentId == null).toList();
    
    // 2. Sort roots by date descending (newest first)
    rootComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return rootComments;
  }

  // Get replies for a specific parent comment
  List<Comment> _getReplies(String parentId) {
    final replies = _comments.where((c) => c.parentId == parentId).toList();
    replies.sort((a, b) => a.createdAt.compareTo(b.createdAt)); // Oldest first for replies usually
    return replies;
  }

  @override
  Widget build(BuildContext context) {
    final sortedComments = _getSortedComments();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Comments (${_loading ? "…" : _comments.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    IconButton(
                      icon: Icon(PhosphorIcons.x()),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Scrollable list (top comments first; scroll to see more)
              Expanded(
                child: _loading
                    ? const Center(child: AppLoader())
                    : sortedComments.isEmpty
                        ? const Center(child: Text('No comments yet'))
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 80),
                            itemCount: sortedComments.length,
                            itemBuilder: (context, index) {
                              final comment = sortedComments[index];
                              final replies = _getReplies(comment.id);
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Parent Comment
                                  CommentItem(
                                    comment: comment,
                                    currentUserId: _currentUserId,
                                    onReply: () {
                                      setState(() {
                                        _replyToId = comment.id;
                                        _replyToUser = comment.authorName;
                                      });
                                    },
                                    onDelete: () => _deleteComment(comment.id),
                                  ),
                                  
                                  // Nested Replies
                                  if (replies.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 32.0),
                                      child: Column(
                                        children: replies.map((reply) => CommentItem(
                                          comment: reply,
                                          currentUserId: _currentUserId,
                                          isReply: true,
                                          onReply: () {
                                            setState(() {
                                              _replyToId = comment.id;
                                              _replyToUser = reply.authorName;
                                            });
                                          },
                                          onDelete: () => _deleteComment(reply.id),
                                        )).toList(),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
              ),
              
              // Input
              Container(
                padding: EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  top: AppSpacing.md,
                  bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_replyToUser != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Text(
                              'Replying to $_replyToUser',
                              style: const TextStyle(color: AppColors.primary, fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => setState(() {
                                _replyToId = null;
                                _replyToUser = null;
                              }),
                              child: Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), size: 12),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.fill)),
                          color: AppColors.primary,
                          onPressed: _addComment,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

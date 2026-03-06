import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/spacing.dart';
import 'package:magna_coders/core/auth/token_storage.dart';
import 'package:magna_coders/features/comments/data/comments_repository.dart';
import 'package:magna_coders/features/comments/domain/comment.dart';
import 'package:magna_coders/features/comments/ui/widgets/comment_item.dart';
import 'package:magna_coders/features/post_details/ui/widgets/comment_composer.dart';
import 'package:magna_coders/features/jobs/data/jobs_repository.dart';
import 'package:magna_coders/features/jobs/domain/job.dart';
import 'package:magna_coders/features/jobs/ui/widgets/job_card.dart';
import 'package:magna_coders/shared/widgets/app_loader.dart';

import 'package:go_router/go_router.dart';
import 'package:magna_coders/features/feed/data/feed_repository.dart';
import 'package:magna_coders/features/feed/domain/post.dart';
import 'package:magna_coders/features/feed/ui/widgets/feed_post_card.dart';
import 'package:magna_coders/features/projects/domain/project.dart';
import 'package:magna_coders/features/projects/ui/widgets/project_card.dart';
import 'package:magna_coders/features/post_details/ui/pages/post_details_page.dart';
import 'package:magna_coders/features/project_details/ui/pages/project_details_page.dart';
import 'package:magna_coders/features/comments/ui/widgets/comments_sheet.dart';

class JobDetailsPage extends StatefulWidget {
  final String jobId;

  const JobDetailsPage({super.key, required this.jobId});

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  final _jobsRepository = JobsRepository();
  final _commentsRepository = CommentsRepository();
  final _feedRepository = FeedRepository();

  bool _loading = true;
  Job? _job;
  List<Comment> _comments = [];
  String? _replyToId;
  String? _replyToUser;
  String? _currentUserId;

  List<dynamic> _relatedContent = [];
  bool _loadingRelated = false;
  int _page = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUser();
    _loadRelatedPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadRelatedPosts();
    }
  }

  Future<void> _loadRelatedPosts() async {
    if (_loadingRelated || !_hasMore) return;
    
    setState(() => _loadingRelated = true);
    
    try {
      final newContent = await _feedRepository.getMixedFeed(page: _page, limit: 10);
      
      if (mounted) {
        setState(() {
          // Filter out the current job if it appears in related
          final filtered = newContent.where((item) {
            if (item is Job) return item.id != widget.jobId;
            return true;
          }).toList();
          
          if (filtered.isEmpty && newContent.isNotEmpty) {
            _page++;
            _loadingRelated = false;
            _loadRelatedPosts();
            return;
          }

          _relatedContent.addAll(filtered);
          _hasMore = newContent.length >= 10;
          _page++;
          _loadingRelated = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingRelated = false);
    }
  }

  Future<void> _loadUser() async {
    final userId = await TokenStorage.readUserId();
    if (mounted) {
      setState(() => _currentUserId = userId);
    }
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _jobsRepository.getJobById(widget.jobId),
        _commentsRepository.getComments(widget.jobId),
      ]);

      if (mounted) {
        setState(() {
          _job = results[0] as Job?;
          _comments = results[1] as List<Comment>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleSendComment(String text) async {
    final newComment = await _commentsRepository.addComment(
      widget.jobId,
      text,
      parentId: _replyToId,
      isJob: true,
    );

    if (newComment != null && mounted) {
      setState(() {
        _comments.add(newComment);
        _job = _job!.copyWith(commentsCount: _job!.commentsCount + 1);
        _replyToId = null;
        _replyToUser = null;
      });
    }
  }

  Future<void> _deleteComment(String id) async {
    final success = await _commentsRepository.deleteComment(id);
    if (success && mounted) {
      setState(() {
        _comments.removeWhere((c) => c.id == id);
        _job = _job!.copyWith(commentsCount: (_job!.commentsCount - 1).clamp(0, double.infinity).toInt());
      });
    }
  }

  List<Comment> _getSortedComments() {
    final rootComments = _comments.where((c) => c.parentId == null).toList();
    rootComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return rootComments;
  }

  List<Comment> _getReplies(String parentId) {
    final replies = _comments.where((c) => c.parentId == parentId).toList();
    replies.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return replies;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: AppLoader()));
    }

    if (_job == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Job not found')),
      );
    }

    final sortedComments = _getSortedComments();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: JobCard(
                    job: _job!,
                    isDetailView: true,
                    onLike: (updatedJob) {
                      setState(() {
                        _job = updatedJob;
                      });
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
                    child: Text(
                      'Comments (${_comments.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final commentCount = sortedComments.length;
                      final showMaxComments = 6;
                      final visibleComments = commentCount > showMaxComments ? showMaxComments : commentCount;
                      
                      if (index < visibleComments) {
                        final comment = sortedComments[index];
                        final replies = _getReplies(comment.id);

                        return Column(
                          children: [
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
                            if (replies.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 32.0),
                                child: Column(
                                  children: replies.map((reply) => CommentItem(
                                    comment: reply,
                                    isReply: true,
                                    currentUserId: _currentUserId,
                                    onDelete: () => _deleteComment(reply.id),
                                  )).toList(),
                                ),
                              ),
                          ],
                        );
                      } else if (index == visibleComments && commentCount > showMaxComments) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextButton(
                            onPressed: () {},
                            child: Text('View all $commentCount comments'),
                          ),
                        );
                      } else {
                        final hasButton = commentCount > showMaxComments;
                        final relatedIndex = index - visibleComments - (hasButton ? 1 : 0);
                        
                        if (relatedIndex >= 0 && relatedIndex < _relatedContent.length) {
                          final item = _relatedContent[relatedIndex];
                          
                          if (item is Post) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: FeedPostCard(
                                post: item,
                                onOpenPost: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PostDetailsPage(postId: item.id),
                                    ),
                                  );
                                },
                              ),
                            );
                          } else if (item is Project) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProjectDetailsPage(projectId: item.id),
                                  ),
                                ),
                                child: ProjectCard(
                                  project: item,
                                  onComment: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProjectDetailsPage(projectId: item.id),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          } else if (item is Job) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: JobCard(
                                job: item,
                                onComment: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => JobDetailsPage(jobId: item.id),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        } else if (_loadingRelated) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: AppLoader()),
                          );
                        }
                        return const SizedBox.shrink();
                      }
                    },
                    childCount: (sortedComments.length > 6 ? 6 : sortedComments.length) + 
                                (sortedComments.length > 6 ? 1 : 0) + 
                                _relatedContent.length + 
                                (_loadingRelated ? 1 : 0),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
          ),
          CommentComposer(
            onSend: _handleSendComment,
            replyingToUserName: _replyToUser,
            onCancelReply: () {
              setState(() {
                _replyToId = null;
                _replyToUser = null;
              });
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/features/comments/ui/widgets/comments_sheet.dart';
import 'package:magna_coders/features/feed/data/feed_repository.dart';
import 'package:magna_coders/features/feed/domain/post.dart';
import 'package:magna_coders/features/feed/ui/widgets/feed_post_card.dart';
import 'package:magna_coders/features/feed/ui/widgets/feed_filter_bar.dart';
import 'package:magna_coders/features/projects/data/projects_repository.dart';
import 'package:magna_coders/features/projects/domain/project.dart';
import 'package:magna_coders/features/projects/ui/widgets/project_card.dart';
import 'package:magna_coders/features/jobs/data/jobs_repository.dart';
import 'package:magna_coders/features/jobs/domain/job.dart';
import 'package:magna_coders/features/jobs/ui/widgets/job_card.dart';
import 'package:magna_coders/shared/widgets/app_loader.dart';
import 'package:magna_coders/shared/widgets/empty_state.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with SingleTickerProviderStateMixin {
  final _feedRepository = FeedRepository();
  final _projectsRepository = ProjectsRepository();
  final _jobsRepository = JobsRepository();
  bool _loading = true;
  List<dynamic> _feedItems = []; // Can be Post, Project, or Job
  String _selectedCategory = 'All';

  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isMenuOpen = false;

  // Map category names to post_type values
  String? _getPostTypeForCategory(String category) {
    switch (category) {
      case 'Projects':
        return 'project';
      case 'Jobs':
        return 'job';
      case 'Posts':
        return 'regular'; // Assuming 'regular' is for standard posts
      case 'Tech News':
        return 'news';
      case 'All':
      default:
        return null;
    }
  }

  List<dynamic> get _filteredFeed {
    if (_selectedCategory == 'All') return _feedItems;
    
    if (_selectedCategory == 'Projects') {
      return _feedItems.whereType<Project>().toList();
    }

    if (_selectedCategory == 'Jobs') {
      return _feedItems.whereType<Job>().toList();
    }
    
    // For other categories, filter posts
    final type = _getPostTypeForCategory(_selectedCategory);
    return _feedItems.whereType<Post>().where((post) => post.postType == type).toList();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadFeed();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _closeMenu() {
    if (_isMenuOpen) {
      setState(() {
        _isMenuOpen = false;
        _animationController.reverse();
      });
    }
  }

  Future<void> _loadFeed() async {
    setState(() => _loading = true);
    
    try {
      // Parallel fetch
      final results = await Future.wait([
        _feedRepository.getFeed(),
        _projectsRepository.getProjects(),
        _jobsRepository.getJobs(),
      ]);
      
      final posts = results[0] as List<Post>;
      final projects = results[1] as List<Project>;
      final jobs = results[2] as List<Job>;
      
      // Merge and sort by date (newest first)
      final allItems = [...posts, ...projects, ...jobs];
      allItems.sort((a, b) {
        DateTime dateA;
        if (a is Post) dateA = a.createdAt;
        else if (a is Project) dateA = a.createdAt;
        else if (a is Job) dateA = a.createdAt;
        else dateA = DateTime.now();
        
        DateTime dateB;
        if (b is Post) dateB = b.createdAt;
        else if (b is Project) dateB = b.createdAt;
        else if (b is Job) dateB = b.createdAt;
        else dateB = DateTime.now();
        
        return dateB.compareTo(dateA);
      });

      if (mounted) {
        setState(() {
          _feedItems = allItems;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Feed Load Error: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _likePost(String postId) async {
    // Optimistic update could be added here
    final success = await _feedRepository.likePost(postId);
    if (success) {
      // Refresh or update local state
      _loadFeed(); // Simple refresh for now
    }
  }

  void _handleItemLiked(dynamic likedItem) {
    if (mounted) {
      setState(() {
        _feedItems = _feedItems.map((item) {
          if (item is Post && likedItem is Post && item.id == likedItem.id) {
            return likedItem;
          } else if (item is Job && likedItem is Job && item.id == likedItem.id) {
            return likedItem;
          } else if (item is Project && likedItem is Project && item.id == likedItem.id) {
            return likedItem;
          }
          return item;
        }).toList();
      });
    }
  }

  Widget _buildMenuItem(String label, IconData icon, VoidCallback onPressed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _expandAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        ScaleTransition(
          scale: _expandAnimation,
          child: FloatingActionButton.small(
            heroTag: label,
            onPressed: () {
              _toggleMenu();
              onPressed();
            },
            backgroundColor: AppColors.primary,
            child: PhosphorIcon(icon, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Magna Feed'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: PhosphorIcon(PhosphorIcons.magnifyingGlass()),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isMenuOpen) ...[
            _buildMenuItem('Create Job', PhosphorIcons.briefcase(), () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create Job coming soon!')),
              );
            }),
            const SizedBox(height: 16),
            _buildMenuItem('Create Project', PhosphorIcons.folderPlus(), () {
              context.push('/create-project');
            }),
            const SizedBox(height: 16),
            _buildMenuItem('Create Post', PhosphorIcons.notePencil(), () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create Post coming soon!')),
              );
            }),
            const SizedBox(height: 16),
          ],
          FloatingActionButton(
            heroTag: 'main-fab',
            onPressed: _toggleMenu,
            backgroundColor: AppColors.primary,
            child: AnimatedRotation(
              turns: _isMenuOpen ? 0.125 : 0, // rotate by 45 degrees
              duration: const Duration(milliseconds: 250),
              child: PhosphorIcon(PhosphorIcons.plus(), color: Colors.white),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Filter Bar
              FeedFilterBar(
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() => _selectedCategory = category);
                },
              ),
              
              Expanded(
                child: _loading
                    ? const AppLoader()
                    : _filteredFeed.isEmpty
                        ? EmptyState(
                            title: 'No content found',
                            message: _selectedCategory == 'All' 
                                ? 'Start by creating your first post or project!'
                                : 'No content found for $_selectedCategory',
                            action: ElevatedButton(
                              onPressed: _loadFeed,
                              child: const Text('Refresh'),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadFeed,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredFeed.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final item = _filteredFeed[index];
                                // debugPrint('Rendering Item $index: ${item.runtimeType}');
                                
                                if (item is Project) {
                                  return InkWell(
                                    key: ValueKey('project_${item.id}'),
                                    onTap: () => context.push('/project/${item.id}'),
                                    child: ProjectCard(
                                      project: item,
                                      onLike: _handleItemLiked,
                                      onComment: () {
                                        context.push('/project/${item.id}');
                                      },
                                    ),
                                  );
                                } else if (item is Job) {
                                  return InkWell(
                                    key: ValueKey('job_${item.id}'),
                                    onTap: () => context.push('/job/${item.id}'),
                                    child: JobCard(
                                      job: item,
                                      onApply: () {},
                                      onViewJob: () => context.push('/job/${item.id}'),
                                      onLike: _handleItemLiked,
                                      onComment: () {
                                         context.push('/job/${item.id}');
                                       },
                                      onShare: () {},
                                    ),
                                  );
                                } else if (item is Post) {
                                  return FeedPostCard(
                                    key: ValueKey('post_${item.id}'),
                                    post: item,
                                    onLike: _handleItemLiked,
                                    onComment: () {
                                      context.push('/post/${item.id}');
                                    },
                                    onShare: () {
                                      // Share post
                                    },
                                    onOpenPost: () {
                                      context.push('/post/${item.id}');
                                    },
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
              ),
            ],
          ),
          if (_isMenuOpen)
            GestureDetector(
              onTap: _closeMenu,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/features/feed/data/feed_repository.dart';
import 'package:magna_coders/features/feed/domain/post.dart';
import 'package:magna_coders/features/feed/ui/widgets/feed_card.dart';
import 'package:magna_coders/shared/widgets/app_loader.dart';
import 'package:magna_coders/shared/widgets/empty_state.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _repository = FeedRepository();
  bool _loading = true;
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    setState(() => _loading = true);
    final posts = await _repository.getFeed();
    if (mounted) {
      setState(() {
        _posts = posts;
        _loading = false;
      });
    }
  }

  Future<void> _likePost(String postId) async {
    // Optimistic update could be added here
    final success = await _repository.likePost(postId);
    if (success) {
      // Refresh or update local state
      _loadFeed(); // Simple refresh for now
    }
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create post
          // context.push('/create-post');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create Post coming soon!')),
          );
        },
        backgroundColor: AppColors.primary,
        child: PhosphorIcon(PhosphorIcons.plus(), color: Colors.white),
      ),
      body: _loading
          ? const AppLoader()
          : _posts.isEmpty
              ? EmptyState(
                  title: 'No posts yet',
                  message: 'Start by creating your first post!',
                  action: ElevatedButton(
                    onPressed: _loadFeed,
                    child: const Text('Retry'),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFeed,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return FeedCard(
                        post: post,
                        onLike: () => _likePost(post.id),
                        onComment: () {
                          // Navigate to post details
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

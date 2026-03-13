import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/builders/data/builders_repository.dart';
import 'package:magna_coders/features/builders/domain/user.dart';
import 'package:magna_coders/features/builders/ui/widgets/builder_card.dart';
import 'package:magna_coders/shared/widgets/app_loader.dart';
import 'package:magna_coders/shared/widgets/empty_state.dart';

class BuildersPage extends StatefulWidget {
  const BuildersPage({super.key});

  @override
  State<BuildersPage> createState() => _BuildersPageState();
}

class _BuildersPageState extends State<BuildersPage> {
  final _repository = BuildersRepository();
  bool _loading = true;
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _loadBuilders();
  }

  Future<void> _loadBuilders() async {
    setState(() => _loading = true);
    final users = await _repository.getBuilders();
    if (mounted) {
      setState(() {
        _users = users;
        _loading = false;
      });
    }
  }

  BuilderCardData _mapUserToCardData(User user) {
    final List<BuilderSocialLink> socialLinks = [];
    if (user.githubUrl != null) {
      socialLinks.add(BuilderSocialLink(type: 'github', label: 'GitHub', url: user.githubUrl!));
    }
    if (user.linkedinUrl != null) {
      socialLinks.add(BuilderSocialLink(type: 'linkedin', label: 'LinkedIn', url: user.linkedinUrl!));
    }
    if (user.twitterUrl != null) {
      socialLinks.add(BuilderSocialLink(type: 'twitter', label: 'Twitter', url: user.twitterUrl!));
    }
    if (user.whatsappUrl != null) {
      socialLinks.add(BuilderSocialLink(type: 'whatsapp', label: 'WhatsApp', url: user.whatsappUrl!));
    }
    if (user.websiteUrl != null) {
      socialLinks.add(BuilderSocialLink(type: 'website', label: 'Website', url: user.websiteUrl!));
    }

    return BuilderCardData(
      id: user.id,
      name: user.username,
      avatarUrl: user.avatarUrl,
      headline: user.tagline ?? user.role ?? 'Magna Builder',
      location: user.location,
      bio: user.bio,
      socialLinks: socialLinks,
      isAvailable: true, // Default to true for now
      categories: user.categories,
      skills: user.skills,
      lookingFor: user.lookingFor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Builders'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: PhosphorIcon(PhosphorIcons.magnifyingGlass()),
            onPressed: () {},
          ),
          IconButton(
            icon: PhosphorIcon(PhosphorIcons.list()),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ],
      ),
      body: _loading
          ? const AppLoader()
          : _users.isEmpty
              ? EmptyState(
                  title: 'No builders found',
                  message: 'Connect with other builders in the community!',
                  action: ElevatedButton(
                    onPressed: _loadBuilders,
                    child: const Text('Retry'),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBuilders,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _users.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return BuilderCard(
                        builder: _mapUserToCardData(user),
                        onCardTap: () => context.push(
                          '/builders/${user.id}',
                          extra: user,
                        ),
                        onConnectTap: () {},
                        onMessageTap: () {
                          context.push(
                            '/messages/direct/${user.id}',
                            extra: {
                              'builderName': user.username,
                              'builderAvatarUrl': user.avatarUrl,
                            },
                          );
                        },
                        onSocialTap: (link) {},
                      );
                    },
                  ),
                ),
    );
  }
}

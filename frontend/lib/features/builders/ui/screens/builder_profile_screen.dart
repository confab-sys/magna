import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/features/builders/domain/user.dart';
import 'package:magna_coders/shared/widgets/app_loader.dart';
import 'package:magna_coders/features/builders/ui/widgets/builder_profile_widgets.dart';

// Temporary sample profile used when no initial user is provided yet.
// TODO: Replace with real API call and remove this mock.
const sampleBuilderProfile = BuilderProfile(
  id: 'sample',
  name: 'Magna Builder',
  avatarUrl: null,
  coverPhotoUrl: null,
  headline: 'Senior Flutter Developer | Magna Community',
  location: 'Nairobi, Kenya',
  isVerified: true,
  isAvailable: true,
  roles: ['Developer', 'Builder'],
  connectionsCount: 120,
  mutualConnectionsCount: 8,
  bio:
      'Passionate builder in the Magna community. This is placeholder profile data until the API wiring is complete.',
  skills: ['Flutter', 'Dart', 'Firebase'],
  projects: [],
  activities: [],
  connections: [],
  githubUrl: null,
  linkedinUrl: null,
  twitterUrl: null,
  whatsappUrl: null,
);

// --- SCREEN ---

class BuilderProfileScreen extends StatefulWidget {
  final String builderId;
  final User? initialUser;

  const BuilderProfileScreen({
    super.key,
    required this.builderId,
    this.initialUser,
  });

  @override
  State<BuilderProfileScreen> createState() => _BuilderProfileScreenState();
}

class _BuilderProfileScreenState extends State<BuilderProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BuilderProfile? _profile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadProfile();
  }

  void _loadProfile() {
    if (widget.initialUser != null) {
      _profile = _mapUserToProfile(widget.initialUser!);
      // Optionally fetch more details in background
      return;
    }

    // If no initial user, fetch from ID (simulated)
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _profile = sampleBuilderProfile;
        _isLoading = false;
      });
    }
  }

  BuilderProfile _mapUserToProfile(User user) {
    return BuilderProfile(
      id: user.id,
      name: user.username,
      avatarUrl: user.avatarUrl,
      coverPhotoUrl: user.coverPhotoUrl,
      headline: user.tagline ?? user.role ?? 'Magna Builder',
      location: user.location ?? 'Unknown Location',
      bio: user.bio ?? 'No bio available',
      skills: user.skills,
      roles: user.categories.isNotEmpty ? user.categories : (user.role != null ? [user.role!] : ['Builder']),
      // Mock data for fields not in User model yet
      isVerified: false,
      isAvailable: true,
      connectionsCount: 0,
      mutualConnectionsCount: 0,
      projects: [], // Use sample projects for now
      activities: [],
      connections: [],
      githubUrl: user.githubUrl,
      linkedinUrl: user.linkedinUrl,
      twitterUrl: user.twitterUrl,
      whatsappUrl: user.whatsappUrl,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: AppLoader());
    }

    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Builder not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final profile = _profile!;

    // Enforce light theme for this screen as per requirements
    return Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // 1. App Header
              SliverAppBar(
                pinned: true,
                floating: true,
                snap: true,
                actions: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.list)),
                ],
              ),
              // 2. Profile Hero Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ProfileHeroCard(profile: profile),
                ),
              ),
              // 3. Tab Navigation
              SliverPersistentHeader(
                pinned: true,
                delegate: BuilderProfileTabBarHeader(
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade400
                            : Colors.grey,
                    indicatorColor: AppColors.primary,
                    indicatorSize: TabBarIndicatorSize.label,
                    isScrollable: true,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Skills'),
                      Tab(text: 'Projects'),
                      Tab(text: 'Activities'),
                      Tab(text: 'Connections'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              BuilderOverviewTab(profile: profile),
              BuilderSkillsTab(skills: profile.skills),
              BuilderProjectsTab(projects: profile.projects),
              BuilderActivitiesTab(activities: profile.activities),
              BuilderConnectionsTab(connections: profile.connections),
            ],
          ),
        ),
      );
  }
}
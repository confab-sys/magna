import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/shared/widgets/app_card.dart';
import 'package:magna_coders/features/builders/ui/widgets/builder_card.dart';

// --- DATA MODELS USED BY BUILDER PROFILE UI ---

class BuilderProfile {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? coverPhotoUrl;
  final String headline;
  final String location;
  final bool isVerified;
  final bool isAvailable;
  final List<String> roles;
  final int connectionsCount;
  final int mutualConnectionsCount;
  final String bio;
  final List<String> skills;
  final List<BuilderProject> projects;
  final List<BuilderActivity> activities;
  final List<BuilderConnection> connections;

  final String? githubUrl;
  final String? linkedinUrl;
  final String? twitterUrl;
  final String? whatsappUrl;

  const BuilderProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.coverPhotoUrl,
    required this.headline,
    required this.location,
    this.isVerified = false,
    this.isAvailable = false,
    required this.roles,
    this.connectionsCount = 0,
    this.mutualConnectionsCount = 0,
    required this.bio,
    this.skills = const [],
    this.projects = const [],
    this.activities = const [],
    this.connections = const [],
    this.githubUrl,
    this.linkedinUrl,
    this.twitterUrl,
    this.whatsappUrl,
  });
}

class BuilderProject {
  final String id;
  final String title;
  final String description;
  final List<String> techStack;
  final String status;
  final String? link;

  const BuilderProject({
    required this.id,
    required this.title,
    required this.description,
    required this.techStack,
    required this.status,
    this.link,
  });
}

class BuilderActivity {
  final String id;
  final IconData icon;
  final String description;
  final DateTime timestamp;

  const BuilderActivity({
    required this.id,
    required this.icon,
    required this.description,
    required this.timestamp,
  });
}

class BuilderConnection {
  final String id;
  final String name;
  final String? avatarUrl;
  final String role;

  const BuilderConnection({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.role,
  });
}

// --- PROFILE HERO & TABS WIDGETS ---

class ProfileHeroCard extends StatelessWidget {
  final BuilderProfile profile;

  const ProfileHeroCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero, // Remove default padding to let cover photo stretch
      child: Column(
        children: [
          // Cover Photo & Avatar Stack
          SizedBox(
            height: 200, // Cover (140) + Avatar Overlap (60)
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Cover Photo Area
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900, // Fallback background
                    ),
                    child: profile.coverPhotoUrl != null
                        ? Image.network(
                            profile.coverPhotoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildFallbackCover(),
                          )
                        : _buildFallbackCover(),
                  ),
                ),

                // 2. QR Code Button
                Positioned(
                  top: 16,
                  right: 16,
                  child: InkWell(
                    onTap: () {
                      // TODO: Show QR Code
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // 3. Avatar (Overlapping)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4), // White border
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .scaffoldBackgroundColor, // Match card/scaffold bg
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: profile.avatarUrl != null
                                ? NetworkImage(profile.avatarUrl!)
                                : null,
                            child: profile.avatarUrl == null
                                ? Text(
                                    profile.name.isNotEmpty
                                        ? profile.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        if (profile.isAvailable)
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content below avatar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              children: [
                // Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Location
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      profile.location,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Roles
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: profile.roles.map((role) {
                    return Chip(
                      label: Text(role),
                      backgroundColor: Theme.of(context).cardColor,
                      labelStyle: const TextStyle(fontSize: 12),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                // Stats
                Text(
                  '${profile.connectionsCount} connections • ${profile.mutualConnectionsCount} mutual connections',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF9940),
                              Color(0xFFE70008)
                            ], // Orange to Red
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Text(
                            'Connect',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          fixedSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          side: BorderSide(
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          'Message',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackCover() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE70008), Color(0xFFFF9940)], // Magna Red to Orange
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.code,
          color: Colors.white.withOpacity(0.2),
          size: 64,
        ),
      ),
    );
  }
}

class BuilderOverviewTab extends StatelessWidget {
  final BuilderProfile profile;

  const BuilderOverviewTab({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // About Card
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  profile.bio,
                  style: const TextStyle(height: 1.4),
                ),
                const SizedBox(height: 16),
                if (profile.githubUrl != null ||
                    profile.linkedinUrl != null ||
                    profile.twitterUrl != null ||
                    profile.whatsappUrl != null)
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (profile.githubUrl != null)
                        _SocialLinkItem(
                          link: BuilderSocialLink(
                            type: 'github',
                            label: 'GitHub',
                            url: profile.githubUrl!,
                          ),
                        ),
                      if (profile.linkedinUrl != null)
                        _SocialLinkItem(
                          link: BuilderSocialLink(
                            type: 'linkedin',
                            label: 'LinkedIn',
                            url: profile.linkedinUrl!,
                          ),
                        ),
                      if (profile.twitterUrl != null)
                        _SocialLinkItem(
                          link: BuilderSocialLink(
                            type: 'twitter',
                            label: 'Twitter',
                            url: profile.twitterUrl!,
                          ),
                        ),
                      if (profile.whatsappUrl != null)
                        _SocialLinkItem(
                          link: BuilderSocialLink(
                            type: 'whatsapp',
                            label: 'WhatsApp',
                            url: profile.whatsappUrl!,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Stats Card
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatRow('Connections',
                    profile.connectionsCount.toString()),
                const Divider(),
                _buildStatRow('Projects', profile.projects.length.toString()),
                const Divider(),
                _buildStatRow('Skills', profile.skills.length.toString()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Availability Card
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Availability',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (profile.isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Available for work',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Text(
                    'Not currently looking for new opportunities.',
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class BuilderSkillsTab extends StatelessWidget {
  final List<String> skills;

  const BuilderSkillsTab({super.key, required this.skills});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: skills.map((skill) {
          return Chip(
            label: Text(skill),
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BuilderProjectsTab extends StatelessWidget {
  final List<BuilderProject> projects;

  const BuilderProjectsTab({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const Center(child: Text('No projects yet.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final project = projects[index];
        return AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: project.status == 'Completed'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        project.status,
                        style: TextStyle(
                          fontSize: 12,
                          color: project.status == 'Completed'
                              ? Colors.green
                              : Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(project.description),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: project.techStack.map((tech) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tech,
                        style: const TextStyle(fontSize: 11),
                      ),
                    );
                  }).toList(),
                ),
                if (project.link != null) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        const Icon(
                          Icons.link,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'View Project',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class BuilderActivitiesTab extends StatelessWidget {
  final List<BuilderActivity> activities;

  const BuilderActivitiesTab({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(child: Text('No activities yet.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Icon(activity.icon, color: Colors.blue, size: 20),
          ),
          title: Text(activity.description),
          subtitle: Text(
            '${activity.timestamp.day}/${activity.timestamp.month}/${activity.timestamp.year}',
            style: const TextStyle(fontSize: 12),
          ),
          contentPadding: EdgeInsets.zero,
        );
      },
    );
  }
}

class BuilderConnectionsTab extends StatelessWidget {
  final List<BuilderConnection> connections;

  const BuilderConnectionsTab({super.key, required this.connections});

  @override
  Widget build(BuildContext context) {
    if (connections.isEmpty) {
      return const Center(child: Text('No connections yet.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: connections.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final connection = connections[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            backgroundImage: connection.avatarUrl != null
                ? NetworkImage(connection.avatarUrl!)
                : null,
            child: connection.avatarUrl == null
                ? Text(connection.name[0])
                : null,
          ),
          title: Text(
            connection.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(connection.role),
          trailing: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Message'),
          ),
        );
      },
    );
  }
}

/// Sliver header delegate for the profile's TabBar.
class BuilderProfileTabBarHeader extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  BuilderProfileTabBarHeader(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: tabBar.preferredSize.height,
      color: Theme.of(context).scaffoldBackgroundColor, // Match background
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(BuilderProfileTabBarHeader oldDelegate) {
    return false;
  }
}

// --- INTERNAL HELPERS ---

class _SocialLinkItem extends StatelessWidget {
  final BuilderSocialLink link;

  const _SocialLinkItem({required this.link});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Open URL
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getSocialIcon(link.type),
          const SizedBox(width: 4),
          Text(
            link.label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSocialIcon(String type) {
    IconData iconData;
    switch (type.toLowerCase()) {
      case 'github':
        iconData = PhosphorIcons.githubLogo();
        break;
      case 'twitter':
        iconData = PhosphorIcons.twitterLogo();
        break;
      case 'linkedin':
        iconData = PhosphorIcons.linkedinLogo();
        break;
      case 'whatsapp':
        iconData = PhosphorIcons.whatsappLogo();
        break;
      default:
        iconData = PhosphorIcons.globe();
    }
    return PhosphorIcon(iconData, size: 16, color: AppColors.primary);
  }
}


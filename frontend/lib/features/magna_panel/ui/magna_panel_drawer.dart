import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/shared/widgets/panel_nav_item.dart';
import 'package:magna_coders/shared/widgets/panel_feature_card.dart';
import 'package:magna_coders/shared/widgets/panel_section_header.dart';
import 'package:magna_coders/features/magna_panel/ui/controllers/panel_controller.dart';

class MagnaPanelDrawer extends StatefulWidget {
  const MagnaPanelDrawer({super.key});

  @override
  State<MagnaPanelDrawer> createState() => _MagnaPanelDrawerState();
}

class _MagnaPanelDrawerState extends State<MagnaPanelDrawer> {
  late final PanelController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PanelController()..addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _handleNavigation(String route) {
    context.go(route);
    // Close drawer after navigation
    if (Scaffold.of(context).isDrawerOpen) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Logout',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Logout',
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _controller.logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final isFeed = currentRoute == '/feed';
    final isProjects = currentRoute == '/projects';
    final isDiscoverGroups = currentRoute == '/messages/discover-groups';
    final isOpportunities = currentRoute == '/jobs';
    final isMagnaAI = currentRoute == '/ai';
    final isMagnaCoin = currentRoute == '/contracts';

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Header (if needed for profile info later)
            const SizedBox(height: 12),

            // Main Navigation Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Core Navigation Items
                    PanelNavItem(
                      icon: isFeed
                          ? PhosphorIcons.house(PhosphorIconsStyle.fill)
                          : PhosphorIcons.house(),
                      label: 'Feed',
                      onPressed: () => _handleNavigation('/feed'),
                      isActive: isFeed,
                    ),
                    const SizedBox(height: 8),
                    PanelNavItem(
                      icon: isProjects
                          ? PhosphorIcons.briefcase(PhosphorIconsStyle.fill)
                          : PhosphorIcons.briefcase(),
                      label: 'Projects',
                      onPressed: () => _handleNavigation('/projects'),
                      isActive: isProjects,
                    ),
                    const SizedBox(height: 8),
                    PanelNavItem(
                      icon: isDiscoverGroups
                          ? PhosphorIcons.chatsCircle(PhosphorIconsStyle.fill)
                          : PhosphorIcons.chatsCircle(),
                      label: 'Discover Groups',
                      onPressed: () => _handleNavigation('/messages/discover-groups'),
                      isActive: isDiscoverGroups,
                    ),
                    const SizedBox(height: 8),
                    PanelNavItem(
                      icon: isOpportunities
                          ? PhosphorIcons.briefcase(PhosphorIconsStyle.fill)
                          : PhosphorIcons.briefcase(),
                      label: 'Opportunities',
                      onPressed: () => _handleNavigation('/jobs'),
                      isActive: isOpportunities,
                    ),
                    const SizedBox(height: 8),
                    PanelNavItem(
                      icon: isMagnaAI
                          ? PhosphorIcons.robot(PhosphorIconsStyle.fill)
                          : PhosphorIcons.robot(),
                      label: 'Magna AI',
                      onPressed: () => _handleNavigation('/ai'),
                      isActive: isMagnaAI,
                    ),
                    const SizedBox(height: 8),
                    PanelNavItem(
                      icon: isMagnaCoin
                          ? PhosphorIcons.coin(PhosphorIconsStyle.fill)
                          : PhosphorIcons.coin(),
                      label: 'Magna Coin',
                      onPressed: () => _handleNavigation('/contracts'),
                      isActive: isMagnaCoin,
                    ),
                    const SizedBox(height: 24),

                    // Feature Section Header
                    const PanelSectionHeader(
                      title: 'EXPLORE & GROW',
                      padding: EdgeInsets.only(left: 16, bottom: 12),
                    ),
                    const SizedBox(height: 8),

                    // Feature Cards
                    PanelFeatureCard(
                      icon: PhosphorIcons.graduationCap(),
                      title: 'Magna School',
                      subtitle: 'Upskill with top tech courses',
                      ctaLabel: 'Start Learning',
                      onCtaPressed: () => _handleNavigation('/courses'),
                    ),
                    const SizedBox(height: 12),
                    PanelFeatureCard(
                      icon: PhosphorIcons.shieldCheck(),
                      title: 'Get Verified',
                      subtitle: 'Boost your credibility and unlock exclusive features.',
                      ctaLabel: 'Apply for Verification',
                      onCtaPressed: () {
                        // TODO: Navigate to verification screen when available
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Verification feature coming soon'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Utility Section (Bottom)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Divider(
                    color: AppColors.border.withOpacity(0.3),
                    height: 20,
                  ),
                  PanelNavItem(
                    icon: PhosphorIcons.gear(),
                    label: 'Settings',
                    onPressed: () => _handleNavigation('/settings'),
                  ),
                  const SizedBox(height: 8),
                  PanelNavItem(
                    icon: PhosphorIcons.signOut(),
                    label: 'Logout',
                    onPressed: _handleLogout,
                    inactiveTextColor: AppColors.error.withOpacity(0.8),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

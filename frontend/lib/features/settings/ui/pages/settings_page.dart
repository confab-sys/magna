import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/features/settings/ui/controllers/settings_controller.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_header.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_navigation.dart';
import 'package:magna_coders/app/theme/typography.dart';

import '../../data/models/settings_module_model.dart';
import '../widgets/modules/account_settings_view.dart';
import '../widgets/modules/payment_method_settings_view.dart';
import '../widgets/modules/payment_history_settings_view.dart';
import '../widgets/modules/my_projects_settings_view.dart';
import '../widgets/modules/my_job_opportunities_settings_view.dart';
import '../widgets/modules/notifications_settings_view.dart';
import '../widgets/modules/privacy_settings_view.dart';
import '../widgets/modules/appearance_settings_view.dart';
import '../widgets/modules/security_settings_view.dart';
import '../widgets/modules/local_discovery_settings_view.dart';
import '../widgets/modules/help_center_settings_view.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SettingsController()..addListener(_onStateChanged);
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isMobile
          ? AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: Icon(PhosphorIcons.arrowLeft(), size: 24),
                onPressed: () => context.go('/'),
              ),
              title: const Text('Settings'),
            )
          : AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: Icon(PhosphorIcons.arrowLeft(), size: 24),
                onPressed: () => context.go('/'),
              ),
              title: const Text('Settings'),
            ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SettingsHeader(
              showMobileMenu: isMobile,
              onMobileMenuPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: AppColors.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Modules',
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 360,
                            child: SettingsNavigation(
                              active: _controller.activeModule,
                              onSelected: (id) {
                                _controller.setActiveModule(id);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            Expanded(
              child: Padding(
                padding: isMobile
                    ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                    : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMobile) ...[
                      SettingsNavigation(
                        active: _controller.activeModule,
                        onSelected: _controller.setActiveModule,
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _buildActiveModule(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveModule() {
    switch (_controller.activeModule) {
      case SettingsModuleId.account:
        return const AccountSettingsView();
      case SettingsModuleId.paymentMethod:
        return const PaymentMethodSettingsView();
      case SettingsModuleId.paymentHistory:
        return const PaymentHistorySettingsView();
      case SettingsModuleId.myProjects:
        return const MyProjectsSettingsView();
      case SettingsModuleId.myJobOpportunities:
        return const MyJobOpportunitiesSettingsView();
      case SettingsModuleId.notifications:
        return const NotificationsSettingsView();
      case SettingsModuleId.privacy:
        return const PrivacySettingsView();
      case SettingsModuleId.appearance:
        return const AppearanceSettingsView();
      case SettingsModuleId.security:
        return const SecuritySettingsView();
      case SettingsModuleId.localDiscovery:
        return const LocalDiscoverySettingsView();
      case SettingsModuleId.helpCenter:
        return const HelpCenterSettingsView();
    }
  }
}

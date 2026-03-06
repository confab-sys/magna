import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/app/bootstrap.dart';
import 'package:magna_coders/features/auth/ui/login_page.dart';
import 'package:magna_coders/features/auth/ui/register_page.dart';
import 'package:magna_coders/features/auth/ui/oauth_callback_page.dart';
import 'package:magna_coders/features/feed/ui/feed_page.dart';
import 'package:magna_coders/features/builders/ui/builders_page.dart';
import 'package:magna_coders/features/messages/ui/chats_page.dart';
import 'package:magna_coders/features/messages/ui/chat_messages_page.dart';
import 'package:magna_coders/features/notifications/ui/notifications_page.dart';
import 'package:magna_coders/features/magna_ai/ui/ai_page.dart';
import 'package:magna_coders/features/projects/ui/projects_page.dart';
import 'package:magna_coders/features/jobs/ui/jobs_page.dart';
import 'package:magna_coders/features/contracts/ui/contracts_page.dart';
import 'package:magna_coders/features/magna_school/ui/courses_page.dart';
import 'package:magna_coders/features/magna_podcast/ui/podcasts_page.dart';

import 'package:magna_coders/features/post_details/ui/pages/post_details_page.dart';
import 'package:magna_coders/features/project_details/ui/pages/project_details_page.dart';
import 'package:magna_coders/features/job_details/ui/pages/job_details_page.dart';
import 'package:magna_coders/features/projects/ui/pages/create_project_page.dart';
import 'package:magna_coders/features/jobs/ui/pages/create_job_page.dart';
import 'package:magna_coders/features/feed/ui/pages/create_post_page.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppShell({super.key, required this.navigationShell});

  static final tabs = [
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIcons.house()),
      selectedIcon: PhosphorIcon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
      label: 'Feed',
    ),
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIcons.wrench()),
      selectedIcon: PhosphorIcon(PhosphorIcons.wrench(PhosphorIconsStyle.fill)),
      label: 'Builders',
    ),
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIcons.chatsCircle()),
      selectedIcon: PhosphorIcon(PhosphorIcons.chatsCircle(PhosphorIconsStyle.fill)),
      label: 'Chats',
    ),
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIcons.bell()),
      selectedIcon: PhosphorIcon(PhosphorIcons.bell(PhosphorIconsStyle.fill)),
      label: 'Notifications',
    ),
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIcons.robot()),
      selectedIcon: PhosphorIcon(PhosphorIcons.robot(PhosphorIconsStyle.fill)),
      label: 'Magna AI',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: tabs,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/feed',
    debugLogDiagnostics: false,
    refreshListenable: AppBootstrap.authState,
    redirect: (context, state) {
      if (!AppBootstrap.isReady.value) {
        return null;
      }
      
      final loggedIn = AppBootstrap.authState.value;
      final location = state.matchedLocation;
      
      // Allow access to login/register if not logged in
      if (!loggedIn) {
        if (location == '/login' || location == '/register' || location.startsWith('/oauth')) {
          return null;
        }
        return '/login';
      }

      // If logged in and trying to access login/register, redirect to feed
      if (loggedIn) {
        if (location == '/login' || location == '/register' || location == '/') {
          return '/feed';
        }
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/post/:postId',
        builder: (context, state) {
          final postId = state.pathParameters['postId']!;
          return PostDetailsPage(postId: postId);
        },
      ),
      GoRoute(
        path: '/project/:projectId',
        builder: (context, state) => ProjectDetailsPage(
          projectId: state.pathParameters['projectId']!,
        ),
      ),
      GoRoute(
        path: '/create-project',
        builder: (context, state) => const CreateProjectPage(),
      ),
      GoRoute(
        path: '/create-job',
        builder: (context, state) => const CreateJobPage(),
      ),
      GoRoute(
        path: '/create-post',
        builder: (context, state) => const CreatePostPage(),
      ),
      GoRoute(
        path: '/job/:jobId',
        builder: (context, state) {
          final jobId = state.pathParameters['jobId']!;
          return JobDetailsPage(jobId: jobId);
        },
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
          path: '/register', builder: (context, state) => const RegisterPage()),
      // Standalone chat route for direct linking if needed, but nested is better.
      // Let's keep the nested route above as the primary.
      // But we need to ensure push('/chat/:id') matches something.
      // If we use /chats/:id, we should update the push calls.
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) => ChatMessagesPage(
          conversationId: state.pathParameters['id']!,
        ),
      ),
      // Drawer/Menu items accessible via direct link or potential drawer (not implemented yet in AppShell)
      // For now we add them as standalone routes
      GoRoute(path: '/projects', builder: (context, state) => const ProjectsPage()),
      GoRoute(path: '/jobs', builder: (context, state) => const JobsPage()),
      GoRoute(path: '/contracts', builder: (context, state) => const ContractsPage()),
      GoRoute(path: '/courses', builder: (context, state) => const CoursesPage()),
      GoRoute(path: '/podcasts', builder: (context, state) => const PodcastsPage()),
      
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/feed', builder: (context, state) => const FeedPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/builders',
                builder: (context, state) => const BuildersPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/chats',
                builder: (context, state) => const ChatsPage(),
                routes: [
                  GoRoute(
                    path: ':id', // This matches /chats/:id but navigation logic uses /chat/:id
                    // Let's fix navigation to use /chats/:id
                    builder: (context, state) => ChatMessagesPage(
                      conversationId: state.pathParameters['id']!,
                    ),
                  ),
                ]),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/notifications',
                builder: (context, state) => const NotificationsPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/ai', builder: (context, state) => const AIPage()),
          ]),
        ],
      ),
    ],
  );
}

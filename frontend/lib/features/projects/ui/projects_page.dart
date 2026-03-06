import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/projects/data/projects_repository.dart';
import 'package:magna_coders/features/projects/domain/project.dart';
import 'package:magna_coders/features/projects/ui/widgets/project_card.dart';
import 'package:magna_coders/shared/widgets/app_loader.dart';
import 'package:magna_coders/shared/widgets/empty_state.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final _repository = ProjectsRepository();
  bool _loading = true;
  List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _loading = true);
    final projects = await _repository.getProjects();
    if (mounted) {
      setState(() {
        _projects = projects;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: PhosphorIcon(PhosphorIcons.plus()),
            onPressed: () {
              // Navigate to create project
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create Project coming soon!')),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const AppLoader()
          : _projects.isEmpty
              ? EmptyState(
                  title: 'No projects found',
                  message: 'Start by creating your first project!',
                  action: ElevatedButton(
                    onPressed: _loadProjects,
                    child: const Text('Retry'),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProjects,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _projects.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final project = _projects[index];
                      return ProjectCard(project: project);
                    },
                  ),
                ),
    );
  }
}

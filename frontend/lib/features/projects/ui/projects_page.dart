import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/projects/data/projects_repository.dart';
import 'package:magna_coders/features/projects/domain/project.dart';
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
                      return _ProjectCard(project: project);
                    },
                  ),
                ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to project details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: AppTypography.h3.copyWith(fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (project.lookingForContributors)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Hiring',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (project.shortDescription != null) ...[
                const SizedBox(height: 8),
                Text(
                  project.shortDescription!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(PhosphorIcons.code(),
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      project.techStack ?? 'Unknown stack',
                      style: AppTypography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

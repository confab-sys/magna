import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/jobs/data/jobs_repository.dart';
import 'package:magna_coders/features/jobs/domain/job.dart';
import 'package:magna_coders/shared/widgets/app_loader.dart';
import 'package:magna_coders/shared/widgets/empty_state.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final _repository = JobsRepository();
  bool _loading = true;
  List<Job> _jobs = [];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() => _loading = true);
    final jobs = await _repository.getJobs();
    if (mounted) {
      setState(() {
        _jobs = jobs;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: PhosphorIcon(PhosphorIcons.plus()),
            onPressed: () {
              // Navigate to create job
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create Job coming soon!')),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const AppLoader()
          : _jobs.isEmpty
              ? EmptyState(
                  title: 'No jobs found',
                  message: 'No job opportunities available right now.',
                  action: ElevatedButton(
                    onPressed: _loadJobs,
                    child: const Text('Retry'),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadJobs,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _jobs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final job = _jobs[index];
                      return _JobCard(job: job);
                    },
                  ),
                ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Job job;

  const _JobCard({required this.job});

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
          // Navigate to job details
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
                      job.title,
                      style: AppTypography.h3.copyWith(fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (job.jobType != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        job.jobType!.toUpperCase(),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(PhosphorIcons.buildings(),
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Company Name', // Ideally fetched via ID or included in model
                      style: AppTypography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (job.location != null) ...[
                    Icon(PhosphorIcons.mapPin(),
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      job.location!,
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (job.salary != null) ...[
                    Icon(PhosphorIcons.money(),
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      job.salary!,
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

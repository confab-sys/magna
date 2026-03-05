import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/builders/data/builders_repository.dart';
import 'package:magna_coders/features/builders/domain/user.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Builders'),
        centerTitle: false,
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
                      return _BuilderCard(user: user);
                    },
                  ),
                ),
    );
  }
}

class _BuilderCard extends StatelessWidget {
  final User user;

  const _BuilderCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          backgroundImage:
              user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child: user.avatarUrl == null
              ? Text(
                  user.username[0].toUpperCase(),
                  style: AppTypography.h3.copyWith(color: AppColors.primary),
                )
              : null,
        ),
        title: Text(
          user.username,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.tagline != null && user.tagline!.isNotEmpty)
              Text(
                user.tagline!,
                style: AppTypography.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (user.role != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user.role!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.secondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        trailing: Icon(PhosphorIcons.caretRight(),
            color: AppColors.textSecondary, size: 16),
        onTap: () {
          // Navigate to profile details
        },
      ),
    );
  }
}

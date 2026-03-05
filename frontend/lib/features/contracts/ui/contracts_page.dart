import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/contracts/data/contracts_repository.dart';
import 'package:magna_coders/features/contracts/domain/contract.dart';
import 'package:magna_coders/shared/widgets/app_loader.dart';
import 'package:magna_coders/shared/widgets/empty_state.dart';

class ContractsPage extends StatefulWidget {
  const ContractsPage({super.key});

  @override
  State<ContractsPage> createState() => _ContractsPageState();
}

class _ContractsPageState extends State<ContractsPage> {
  final _repository = ContractsRepository();
  bool _loading = true;
  List<Contract> _contracts = [];

  @override
  void initState() {
    super.initState();
    _loadContracts();
  }

  Future<void> _loadContracts() async {
    setState(() => _loading = true);
    final contracts = await _repository.getContracts();
    if (mounted) {
      setState(() {
        _contracts = contracts;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contracts'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: PhosphorIcon(PhosphorIcons.plus()),
            onPressed: () {
              // Navigate to create contract
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create Contract coming soon!')),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const AppLoader()
          : _contracts.isEmpty
              ? EmptyState(
                  title: 'No active contracts',
                  message: 'No contracts have been created yet.',
                  action: ElevatedButton(
                    onPressed: _loadContracts,
                    child: const Text('Retry'),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadContracts,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _contracts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final contract = _contracts[index];
                      return _ContractCard(contract: contract);
                    },
                  ),
                ),
    );
  }
}

class _ContractCard extends StatelessWidget {
  final Contract contract;

  const _ContractCard({required this.contract});

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
          // Navigate to contract details
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
                      contract.title,
                      style: AppTypography.h3.copyWith(fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusBadge(status: contract.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                contract.description,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: AppTypography.bodySmall,
                  ),
                  Text(
                    '\$${contract.totalAmount.toStringAsFixed(2)}',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
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

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        color = AppColors.success;
        break;
      case 'COMPLETED':
        color = AppColors.primary;
        break;
      case 'CANCELLED':
        color = AppColors.error;
        break;
      default:
        color = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}

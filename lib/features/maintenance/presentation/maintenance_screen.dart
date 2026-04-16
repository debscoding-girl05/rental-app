import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:landlord_os/core/constants/app_colors.dart';
import 'package:landlord_os/core/extensions/datetime_ext.dart';
import 'package:landlord_os/core/extensions/l10n_ext.dart';
import 'package:landlord_os/features/maintenance/domain/maintenance_request_model.dart';
import 'package:landlord_os/features/maintenance/presentation/maintenance_controller.dart';
import 'package:landlord_os/shared/widgets/empty_state_widget.dart';
import 'package:landlord_os/shared/widgets/error_widget.dart';

/// Main list screen for maintenance requests with status filter chips.
class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requestsAsync = ref.watch(maintenanceControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.maintenance)),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_maintenance',
        onPressed: () => context.push('/maintenance/add'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // --- Filter chips ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('all', 'All', theme),
                const SizedBox(width: 8),
                ...MaintenanceStatuses.all.map(
                  (status) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      status,
                      MaintenanceStatuses.label(status),
                      theme,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Request list ---
          Expanded(
            child: requestsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => AppErrorWidget(
                message: error.toString(),
                onRetry: () => ref.invalidate(maintenanceControllerProvider),
              ),
              data: (requests) {
                final filtered = _statusFilter == 'all'
                    ? requests
                    : requests.where((r) => r.status == _statusFilter).toList();

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    message: _statusFilter == 'all'
                        ? context.l10n.noMaintenanceRequests
                        : 'No ${MaintenanceStatuses.label(_statusFilter).toLowerCase()} requests.',
                    icon: Icons.build_outlined,
                    actionLabel: context.l10n.addRequest,
                    onAction: () => context.push('/maintenance/add'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _RequestCard(request: filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, ThemeData theme) {
    final selected = _statusFilter == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _statusFilter = value),
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final MaintenanceRequest request;

  Color _priorityColor(String priority) => switch (priority) {
    'urgent' => AppColors.error,
    'high' => AppColors.warning,
    'medium' => AppColors.info,
    _ => AppColors.disabled,
  };

  Color _statusColor(String status, ThemeData theme) => switch (status) {
    'open' => AppColors.error,
    'in_progress' => AppColors.warning,
    'resolved' => AppColors.success,
    _ => theme.colorScheme.onSurface,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => context.push('/maintenance/${request.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with priority badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _priorityColor(
                        request.priority,
                      ).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      MaintenancePriorities.label(request.priority),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _priorityColor(request.priority),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Status chip + date
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(
                        request.status,
                        theme,
                      ).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      MaintenanceStatuses.label(request.status),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _statusColor(request.status, theme),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (request.createdAt != null)
                    Text(
                      request.createdAt!.formatted,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
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

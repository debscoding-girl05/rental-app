import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:landlord_os/core/constants/app_colors.dart';
import 'package:landlord_os/core/extensions/datetime_ext.dart';
import 'package:landlord_os/core/extensions/l10n_ext.dart';
import 'package:landlord_os/core/extensions/num_ext.dart';
import 'package:landlord_os/features/maintenance/domain/maintenance_request_model.dart';
import 'package:landlord_os/features/maintenance/presentation/maintenance_controller.dart';
import 'package:landlord_os/shared/widgets/app_button.dart';
import 'package:landlord_os/shared/widgets/error_widget.dart';

/// Detail view for a single maintenance request.
class MaintenanceDetailScreen extends ConsumerWidget {
  const MaintenanceDetailScreen({required this.maintenanceId, super.key});

  final String maintenanceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(maintenanceControllerProvider);

    return requestsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(maintenanceControllerProvider),
        ),
      ),
      data: (requests) {
        final request = requests
            .where((r) => r.id == maintenanceId)
            .firstOrNull;
        if (request == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const AppErrorWidget(
              message: 'Maintenance request not found.',
            ),
          );
        }
        return _DetailBody(request: request);
      },
    );
  }
}

class _DetailBody extends ConsumerStatefulWidget {
  const _DetailBody({required this.request});

  final MaintenanceRequest request;

  @override
  ConsumerState<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends ConsumerState<_DetailBody> {
  bool _isUpdating = false;

  Color _priorityColor(String priority) => switch (priority) {
    'urgent' => AppColors.error,
    'high' => AppColors.warning,
    'medium' => AppColors.info,
    _ => AppColors.disabled,
  };

  Color _statusColor(String status) => switch (status) {
    'open' => AppColors.error,
    'in_progress' => AppColors.warning,
    'resolved' => AppColors.success,
    _ => AppColors.disabled,
  };

  Future<void> _startWork() async {
    setState(() => _isUpdating = true);
    try {
      await ref
          .read(maintenanceControllerProvider.notifier)
          .updateStatus(widget.request.id, status: 'in_progress');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _markResolved() async {
    final costCtrl = TextEditingController();
    final cost = await showDialog<double?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.markResolved),
        content: TextField(
          controller: costCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: context.l10n.cost,
            prefixIcon: const Icon(Icons.attach_money),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(null),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final parsed = double.tryParse(costCtrl.text.trim());
              ctx.pop(parsed ?? -1.0); // -1 means "no cost provided"
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    // null means dialog was dismissed or Cancel was pressed.
    if (cost == null) return;

    setState(() => _isUpdating = true);
    try {
      await ref
          .read(maintenanceControllerProvider.notifier)
          .updateStatus(
            widget.request.id,
            status: 'resolved',
            cost: cost >= 0 ? cost : null,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.delete),
        content: Text(context.l10n.cannotBeUndone),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: Text(
              context.l10n.delete,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await ref
          .read(maintenanceControllerProvider.notifier)
          .deleteRequest(widget.request.id);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.maintenanceDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: context.l10n.delete,
            onPressed: _delete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Title ---
          Text(req.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),

          // --- Priority & Status badges ---
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _priorityColor(req.priority).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  MaintenancePriorities.label(req.priority),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _priorityColor(req.priority),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(req.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  MaintenanceStatuses.label(req.status),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _statusColor(req.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Description ---
          if (req.description != null && req.description!.isNotEmpty) ...[
            Text(context.l10n.description, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  req.description!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // --- Details ---
          Text('Details', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.flag_outlined,
                    label: context.l10n.priority,
                    value: MaintenancePriorities.label(req.priority),
                  ),
                  _DetailRow(
                    icon: Icons.info_outline,
                    label: context.l10n.status,
                    value: MaintenanceStatuses.label(req.status),
                  ),
                  if (req.cost != null)
                    _DetailRow(
                      icon: Icons.attach_money,
                      label: context.l10n.cost,
                      value: req.cost!.toCurrency(),
                    ),
                  if (req.createdAt != null)
                    _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: context.l10n.requestDate,
                      value: req.createdAt!.formattedWithTime,
                    ),
                  if (req.resolvedAt != null)
                    _DetailRow(
                      icon: Icons.check_circle_outline,
                      label: context.l10n.resolvedDate,
                      value: req.resolvedAt!.formattedWithTime,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Action buttons ---
          if (req.status == 'open')
            AppButton(
              label: context.l10n.startWork,
              icon: Icons.play_arrow_outlined,
              onPressed: _isUpdating ? null : _startWork,
              isLoading: _isUpdating,
            ),
          if (req.status == 'in_progress')
            AppButton(
              label: context.l10n.markResolved,
              icon: Icons.check_circle_outline,
              onPressed: _isUpdating ? null : _markResolved,
              isLoading: _isUpdating,
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

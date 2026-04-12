import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:landlord_os/core/extensions/datetime_ext.dart';
import 'package:landlord_os/core/extensions/num_ext.dart';
import 'package:landlord_os/features/tenants/domain/tenant_model.dart';
import 'package:landlord_os/features/tenants/presentation/tenant_controller.dart';
import 'package:landlord_os/shared/widgets/error_widget.dart';

/// Detail view for a single tenant.
class TenantDetailScreen extends ConsumerWidget {
  const TenantDetailScreen({required this.tenantId, super.key});

  final String tenantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantsAsync = ref.watch(tenantControllerProvider);

    return tenantsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(tenantControllerProvider),
        ),
      ),
      data: (tenants) {
        final tenant = tenants.where((t) => t.id == tenantId).firstOrNull;
        if (tenant == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const AppErrorWidget(message: 'Tenant not found.'),
          );
        }
        return _TenantDetailBody(tenant: tenant);
      },
    );
  }
}

class _TenantDetailBody extends ConsumerWidget {
  const _TenantDetailBody({required this.tenant});

  final Tenant tenant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tenant.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Tenant'),
                  content: Text('Remove "${tenant.fullName}"? This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => ctx.pop(false), child: const Text('Cancel')),
                    TextButton(onPressed: () => ctx.pop(true), child: const Text('Delete')),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await ref.read(tenantControllerProvider.notifier).deleteTenant(tenant.id);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoRow(label: 'Full Name', value: tenant.fullName),
          if (tenant.email != null) _InfoRow(label: 'Email', value: tenant.email!),
          if (tenant.phone != null) _InfoRow(label: 'Phone', value: tenant.phone!),
          _InfoRow(label: 'Rent', value: tenant.rentAmount.toCurrency()),
          if (tenant.depositAmount != null)
            _InfoRow(label: 'Deposit', value: tenant.depositAmount!.toCurrency()),
          if (tenant.leaseStart != null)
            _InfoRow(label: 'Lease Start', value: tenant.leaseStart!.formatted),
          if (tenant.leaseEnd != null)
            _InfoRow(label: 'Lease End', value: tenant.leaseEnd!.formatted),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

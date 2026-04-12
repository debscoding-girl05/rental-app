import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:landlord_os/core/extensions/num_ext.dart';
import 'package:landlord_os/features/tenants/presentation/tenant_controller.dart';
import 'package:landlord_os/shared/widgets/app_card.dart';
import 'package:landlord_os/shared/widgets/empty_state_widget.dart';
import 'package:landlord_os/shared/widgets/error_widget.dart';

/// Lists all tenants across the landlord's properties.
class TenantsScreen extends ConsumerWidget {
  const TenantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantsAsync = ref.watch(tenantControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tenants')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tenants/add'),
        child: const Icon(Icons.person_add),
      ),
      body: tenantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(tenantControllerProvider),
        ),
        data: (tenants) {
          if (tenants.isEmpty) {
            return EmptyStateWidget(
              message: 'No tenants yet.\nAdd your first tenant to get started.',
              icon: Icons.people_outline,
              actionLabel: 'Add Tenant',
              onAction: () => context.push('/tenants/add'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tenants.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tenant = tenants[index];
              return AppCard(
                onTap: () => context.push('/tenants/${tenant.id}'),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      child: Text(
                        tenant.fullName.isNotEmpty ? tenant.fullName[0].toUpperCase() : '?',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tenant.fullName, style: Theme.of(context).textTheme.titleMedium),
                          if (tenant.email != null)
                            Text(
                              tenant.email!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      tenant.rentAmount.toCurrency(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

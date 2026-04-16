import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:landlord_os/core/extensions/l10n_ext.dart';
import 'package:landlord_os/core/extensions/num_ext.dart';
import 'package:landlord_os/core/providers/currency_provider.dart';
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
    final theme = Theme.of(context);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.tenants)),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_tenants',
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
              message:
                  '${context.l10n.noTenants}\n${context.l10n.addYourFirstTenant}',
              icon: Icons.people_outline,
              actionLabel: context.l10n.addTenant,
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
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      child: Text(
                        tenant.fullName.isNotEmpty
                            ? tenant.fullName[0].toUpperCase()
                            : '?',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tenant.fullName,
                            style: theme.textTheme.titleMedium,
                          ),
                          if (tenant.phone != null && tenant.phone!.isNotEmpty)
                            Text(
                              tenant.phone!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      tenant.rentAmount.toCurrencyWith(currency),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.secondary,
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

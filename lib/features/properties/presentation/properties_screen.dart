import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:landlord_os/features/properties/presentation/property_controller.dart';
import 'package:landlord_os/shared/widgets/app_card.dart';
import 'package:landlord_os/shared/widgets/empty_state_widget.dart';
import 'package:landlord_os/shared/widgets/error_widget.dart';

/// Lists all properties in the landlord's portfolio.
class PropertiesScreen extends ConsumerWidget {
  const PropertiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(propertyControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Properties')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/properties/add'),
        child: const Icon(Icons.add),
      ),
      body: propertiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(propertyControllerProvider),
        ),
        data: (properties) {
          if (properties.isEmpty) {
            return EmptyStateWidget(
              message: 'No properties yet.\nAdd your first property to get started.',
              icon: Icons.home_work_outlined,
              actionLabel: 'Add Property',
              onAction: () => context.push('/properties/add'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: properties.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final property = properties[index];
              return AppCard(
                onTap: () => context.push('/properties/${property.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${property.address}, ${property.city}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (property.bedrooms != null) ...[
                          Icon(Icons.bed_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 4),
                          Text('${property.bedrooms} bed'),
                          const SizedBox(width: 16),
                        ],
                        if (property.bathrooms != null) ...[
                          Icon(Icons.bathtub_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 4),
                          Text('${property.bathrooms} bath'),
                        ],
                      ],
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

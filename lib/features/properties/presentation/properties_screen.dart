import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:landlord_os/core/constants/app_colors.dart';
import 'package:landlord_os/features/properties/domain/property_model.dart';
import 'package:landlord_os/features/properties/presentation/property_controller.dart';
import 'package:landlord_os/features/properties/presentation/unit_controller.dart';
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
              message:
                  'No properties yet.\nAdd your first property to get started.',
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
              return _PropertyCard(property: property);
            },
          );
        },
      ),
    );
  }
}

class _PropertyCard extends ConsumerWidget {
  const _PropertyCard({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final unitsAsync = ref.watch(unitControllerProvider(property.id));

    // Compute occupancy from actual units
    int occupiedCount = 0;
    int totalUnitCount = property.totalUnits;

    final unitsData = unitsAsync.valueOrNull;
    if (unitsData != null && unitsData.isNotEmpty) {
      totalUnitCount = unitsData.length;
      occupiedCount = unitsData.where((u) => u.isOccupied).length;
    }

    final isFull = occupiedCount == totalUnitCount && totalUnitCount > 0;
    final isEmpty = occupiedCount == 0;
    final occupancyLabel = '$occupiedCount/$totalUnitCount';

    Color badgeColor;
    String badgeText;
    if (isFull) {
      badgeColor = AppColors.success;
      badgeText = 'Full ($occupancyLabel)';
    } else if (isEmpty) {
      badgeColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);
      badgeText = 'Vacant ($occupancyLabel)';
    } else {
      badgeColor = AppColors.warning;
      badgeText = 'Partial ($occupancyLabel)';
    }

    return AppCard(
      onTap: () => context.push('/properties/${property.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: name + type badge
          Row(
            children: [
              Expanded(
                child: Text(property.name, style: theme.textTheme.titleMedium),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  PropertyTypes.label(property.propertyType),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Location
          Text(
            [
              if (property.quartier != null && property.quartier!.isNotEmpty)
                property.quartier!,
              property.city,
            ].join(', '),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 10),

          // Bottom row: stats + occupancy badge
          Row(
            children: [
              Icon(
                Icons.door_front_door_outlined,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '$totalUnitCount unit${totalUnitCount != 1 ? 's' : ''}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.layers_outlined,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '${property.floors} floor${property.floors != 1 ? 's' : ''}',
                style: theme.textTheme.bodySmall,
              ),
              const Spacer(),
              // Occupancy badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

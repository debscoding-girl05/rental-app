import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:landlord_os/core/extensions/num_ext.dart';
import 'package:landlord_os/features/properties/domain/property_model.dart';
import 'package:landlord_os/features/properties/presentation/property_controller.dart';
import 'package:landlord_os/shared/widgets/error_widget.dart';

/// Detail view for a single property.
class PropertyDetailScreen extends ConsumerWidget {
  const PropertyDetailScreen({required this.propertyId, super.key});

  final String propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(propertyControllerProvider);

    return propertiesAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(propertyControllerProvider),
        ),
      ),
      data: (properties) {
        final property = properties.where((p) => p.id == propertyId).firstOrNull;
        if (property == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const AppErrorWidget(message: 'Property not found.'),
          );
        }
        return _PropertyDetailBody(property: property);
      },
    );
  }
}

class _PropertyDetailBody extends ConsumerWidget {
  const _PropertyDetailBody({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(property.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Property'),
                  content: Text('Delete "${property.name}"? This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => ctx.pop(false), child: const Text('Cancel')),
                    TextButton(onPressed: () => ctx.pop(true), child: const Text('Delete')),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await ref.read(propertyControllerProvider.notifier).deleteProperty(property.id);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoRow(label: 'Address', value: property.address),
          _InfoRow(label: 'City', value: property.city),
          _InfoRow(label: 'Country', value: property.country),
          if (property.bedrooms != null)
            _InfoRow(label: 'Bedrooms', value: '${property.bedrooms}'),
          if (property.bathrooms != null)
            _InfoRow(label: 'Bathrooms', value: '${property.bathrooms}'),
          if (property.sizeSqm != null)
            _InfoRow(label: 'Size', value: '${property.sizeSqm} sqm'),
          if (property.purchasePrice != null)
            _InfoRow(label: 'Purchase Price', value: property.purchasePrice!.toCurrency()),
          if (property.mortgageMonthly != null)
            _InfoRow(label: 'Mortgage/month', value: property.mortgageMonthly!.toCurrency()),
          if (property.notes != null && property.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Notes', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(property.notes!, style: theme.textTheme.bodyMedium),
          ],
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
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

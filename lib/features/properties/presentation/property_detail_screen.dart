import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/constants/app_colors.dart';
import 'package:landlord_os/core/constants/currencies.dart';
import 'package:landlord_os/core/extensions/l10n_ext.dart';
import 'package:landlord_os/core/extensions/num_ext.dart';
import 'package:landlord_os/features/properties/domain/property_model.dart';
import 'package:landlord_os/features/properties/domain/unit_model.dart';
import 'package:landlord_os/features/properties/presentation/edit_unit_screen.dart';
import 'package:landlord_os/features/properties/presentation/property_controller.dart';
import 'package:landlord_os/features/properties/presentation/unit_controller.dart';
import 'package:landlord_os/features/tenants/data/tenant_repository.dart';
import 'package:landlord_os/features/tenants/domain/tenant_model.dart';
import 'package:landlord_os/shared/widgets/empty_state_widget.dart';
import 'package:landlord_os/shared/widgets/error_widget.dart';

/// Detail view for a single property — redesigned with rich UI.
class PropertyDetailScreen extends ConsumerWidget {
  const PropertyDetailScreen({required this.propertyId, super.key});

  final String propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(propertyControllerProvider);

    return propertiesAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(propertyControllerProvider),
        ),
      ),
      data: (properties) {
        final property = properties
            .where((p) => p.id == propertyId)
            .firstOrNull;
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

class _PropertyDetailBody extends ConsumerStatefulWidget {
  const _PropertyDetailBody({required this.property});

  final Property property;

  @override
  ConsumerState<_PropertyDetailBody> createState() =>
      _PropertyDetailBodyState();
}

class _PropertyDetailBodyState extends ConsumerState<_PropertyDetailBody> {
  bool _uploading = false;
  List<Tenant> _tenants = [];

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    try {
      final tenants = await ref.read(tenantRepositoryProvider).getAll();
      if (mounted) setState(() => _tenants = tenants);
    } catch (_) {}
  }

  Tenant? _tenantForUnit(String unitId) {
    return _tenants.where((t) => t.unitId == unitId).firstOrNull;
  }

  Future<void> _uploadPropertyPhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => ctx.pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => ctx.pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final file = await picker.pickImage(source: source, maxWidth: 1400);
    if (file == null) return;

    setState(() => _uploading = true);
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser!.id;
      final ext = file.path.split('.').last;
      final path =
          '$userId/${widget.property.id}/property_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await client.storage
          .from('property-files')
          .upload(
            path,
            File(file.path),
            fileOptions: const FileOptions(upsert: true),
          );

      final url = client.storage.from('property-files').getPublicUrl(path);
      final updatedPhotos = [...widget.property.photos, url];
      await ref
          .read(propertyControllerProvider.notifier)
          .updateProperty(widget.property.copyWith(photos: updatedPhotos));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo added'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _uploadUnitPhoto(Unit unit) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => ctx.pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => ctx.pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final file = await picker.pickImage(source: source, maxWidth: 1200);
    if (file == null) return;

    setState(() => _uploading = true);
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser!.id;
      final ext = file.path.split('.').last;
      final path =
          '$userId/${unit.id}/unit_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await client.storage
          .from('property-files')
          .upload(
            path,
            File(file.path),
            fileOptions: const FileOptions(upsert: true),
          );

      final url = client.storage.from('property-files').getPublicUrl(path);
      await ref
          .read(unitControllerProvider(widget.property.id).notifier)
          .updateUnit(unit.copyWith(photoUrl: url));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unit photo updated'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final theme = Theme.of(context);
    final unitsAsync = ref.watch(unitControllerProvider(property.id));
    final currency = Currencies.fromCode(property.currency);

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
                  title: Text(context.l10n.deleteProperty),
                  content: Text(
                    '${context.l10n.delete} "${property.name}"? ${context.l10n.cannotBeUndone}',
                  ),
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
              if (confirm == true && context.mounted) {
                await ref
                    .read(propertyControllerProvider.notifier)
                    .deleteProperty(property.id);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/properties/${property.id}/units/add'),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.addUnit),
      ),
      body: _uploading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Uploading photo...'),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // --- Photos gallery ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Photos', style: theme.textTheme.titleMedium),
                    TextButton.icon(
                      onPressed: _uploadPropertyPhoto,
                      icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                      label: const Text('Add Photo'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (property.photos.isEmpty)
                  GestureDetector(
                    onTap: _uploadPropertyPhoto,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.05,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 32,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to add property photos',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: property.photos.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        if (index == property.photos.length) {
                          return GestureDetector(
                            onTap: _uploadPropertyPhoto,
                            child: Container(
                              width: 100,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.05,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                              ),
                              child: Icon(
                                Icons.add_a_photo_outlined,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                          );
                        }
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: property.photos[index],
                            width: 180,
                            height: 140,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),

                // --- Property header card ---
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            PropertyTypes.label(property.propertyType),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(
                              label: context.l10n.floors,
                              value: '${property.floors}',
                              icon: Icons.layers_outlined,
                            ),
                            _StatItem(
                              label: context.l10n.units,
                              value: '${property.totalUnits}',
                              icon: Icons.door_front_door_outlined,
                            ),
                            _StatItem(
                              label: context.l10n.currency,
                              value: property.currency,
                              icon: Icons.monetization_on_outlined,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Location ---
                Text('Location', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.location_on_outlined,
                          label: context.l10n.address,
                          value: property.address,
                        ),
                        if (property.quartier != null &&
                            property.quartier!.isNotEmpty)
                          _DetailRow(
                            icon: Icons.map_outlined,
                            label: context.l10n.quartier,
                            value: property.quartier!,
                          ),
                        _DetailRow(
                          icon: Icons.location_city_outlined,
                          label: context.l10n.city,
                          value: property.city,
                        ),
                        _DetailRow(
                          icon: Icons.flag_outlined,
                          label: context.l10n.country,
                          value: property.country,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Financials ---
                if (property.purchasePrice != null ||
                    property.mortgageMonthly != null) ...[
                  Text('Financial Details', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (property.purchasePrice != null)
                            _DetailRow(
                              icon: Icons.account_balance_outlined,
                              label: context.l10n.purchasePrice,
                              value: property.purchasePrice!.toCurrencyWith(
                                currency,
                              ),
                            ),
                          if (property.mortgageMonthly != null)
                            _DetailRow(
                              icon: Icons.credit_card_outlined,
                              label: context.l10n.mortgage,
                              value: property.mortgageMonthly!.toCurrencyWith(
                                currency,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // --- Notes ---
                if (property.notes != null && property.notes!.isNotEmpty) ...[
                  Text(context.l10n.notes, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        property.notes!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // --- Units section ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.l10n.units, style: theme.textTheme.titleLarge),
                    unitsAsync.whenOrNull(
                          data: (units) => Text(
                            '${units.where((u) => u.isOccupied).length}/${units.length} occupied',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ) ??
                        const SizedBox.shrink(),
                  ],
                ),
                const SizedBox(height: 12),

                unitsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => AppErrorWidget(
                    message: error.toString(),
                    onRetry: () =>
                        ref.invalidate(unitControllerProvider(property.id)),
                  ),
                  data: (units) {
                    if (units.isEmpty) {
                      return EmptyStateWidget(
                        message:
                            '${context.l10n.noUnits}\n${context.l10n.addYourFirstUnit}',
                        icon: Icons.door_front_door_outlined,
                        actionLabel: context.l10n.addUnit,
                        onAction: () => context.push(
                          '/properties/${property.id}/units/add',
                        ),
                      );
                    }
                    return Column(
                      children: units
                          .map(
                            (unit) => _UnitTile(
                              unit: unit,
                              currency: currency,
                              tenant: _tenantForUnit(unit.id),
                              onUploadPhoto: () => _uploadUnitPhoto(unit),
                              onEdit: () async {
                                final result = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditUnitScreen(unit: unit),
                                  ),
                                );
                                if (result == true) {
                                  ref.invalidate(
                                    unitControllerProvider(property.id),
                                  );
                                }
                              },
                            ),
                          )
                          .toList(),
                    );
                  },
                ),

                const SizedBox(height: 80), // space for FAB
              ],
            ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
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
            width: 120,
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

class _UnitTile extends StatelessWidget {
  const _UnitTile({
    required this.unit,
    required this.currency,
    required this.onUploadPhoto,
    required this.onEdit,
    this.tenant,
  });

  final Unit unit;
  final Currency currency;
  final VoidCallback onUploadPhoto;
  final VoidCallback onEdit;
  final Tenant? tenant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: onUploadPhoto,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: unit.isOccupied
                        ? theme.colorScheme.secondary.withValues(alpha: 0.1)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    image: unit.photoUrl != null
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(unit.photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: unit.photoUrl == null
                      ? Icon(
                          unit.isOccupied
                              ? Icons.person_outlined
                              : Icons.camera_alt_outlined,
                          color: unit.isOccupied
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                          size: 22,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(unit.unitLabel, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      '${UnitTypes.label(unit.unitType)} - Floor ${unit.floorNumber}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    if (tenant != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              tenant!.fullName,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    unit.rentAmount.toCurrencyWith(currency),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: unit.isOccupied
                          ? AppColors.success.withValues(alpha: 0.1)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      unit.isOccupied
                          ? context.l10n.occupied
                          : context.l10n.vacant,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: unit.isOccupied
                            ? AppColors.success
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
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

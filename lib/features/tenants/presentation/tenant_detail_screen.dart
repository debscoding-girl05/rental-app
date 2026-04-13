import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/constants/app_colors.dart';
import 'package:landlord_os/core/extensions/datetime_ext.dart';
import 'package:landlord_os/core/extensions/num_ext.dart';
import 'package:landlord_os/features/payments/domain/payment_model.dart';
import 'package:landlord_os/features/payments/presentation/payment_controller.dart';
import 'package:landlord_os/features/payments/presentation/payment_history_screen.dart';
import 'package:landlord_os/features/payments/presentation/record_payment_screen.dart';
import 'package:landlord_os/features/properties/data/unit_repository.dart';
import 'package:landlord_os/features/properties/domain/unit_model.dart';
import 'package:landlord_os/features/tenants/domain/tenant_model.dart';
import 'package:landlord_os/features/tenants/presentation/edit_tenant_screen.dart';
import 'package:landlord_os/features/tenants/presentation/tenant_controller.dart';
import 'package:landlord_os/shared/widgets/error_widget.dart';

/// Detail view for a single tenant — redesigned with rich UI.
class TenantDetailScreen extends ConsumerWidget {
  const TenantDetailScreen({required this.tenantId, super.key});

  final String tenantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantsAsync = ref.watch(tenantControllerProvider);

    return tenantsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(tenantControllerProvider),
        ),
      ),
      data: (tenants) {
        final tenant =
            tenants.where((t) => t.id == tenantId).firstOrNull;
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

class _TenantDetailBody extends ConsumerStatefulWidget {
  const _TenantDetailBody({required this.tenant});

  final Tenant tenant;

  @override
  ConsumerState<_TenantDetailBody> createState() =>
      _TenantDetailBodyState();
}

class _TenantDetailBodyState extends ConsumerState<_TenantDetailBody> {
  Unit? _unit;
  bool _unitLoading = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _loadUnit();
  }

  Future<void> _loadUnit() async {
    if (widget.tenant.unitId == null) return;
    setState(() => _unitLoading = true);
    try {
      final allUnits = await ref.read(unitRepositoryProvider).getAll();
      final match = allUnits
          .where((u) => u.id == widget.tenant.unitId)
          .firstOrNull;
      if (mounted) setState(() => _unit = match);
    } catch (_) {}
    finally {
      if (mounted) setState(() => _unitLoading = false);
    }
  }

  Future<void> _uploadFile(String field) async {
    final picker = ImagePicker();
    final XFile? file;

    if (field == 'lease_document') {
      // For lease documents, allow picking any file via gallery (as a workaround)
      file = await picker.pickImage(source: ImageSource.gallery);
    } else {
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
      file = await picker.pickImage(source: source, maxWidth: 1200);
    }

    if (file == null) return;

    setState(() => _uploading = true);
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser!.id;
      final ext = file.path.split('.').last;
      final path = '$userId/${widget.tenant.id}/${field}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await client.storage.from('tenant-files').upload(
            path,
            File(file.path),
            fileOptions: const FileOptions(upsert: true),
          );

      final url = client.storage.from('tenant-files').getPublicUrl(path);

      // Update tenant with new URL
      final updated = switch (field) {
        'photo' => widget.tenant.copyWith(photoUrl: url),
        'id_photo' => widget.tenant.copyWith(idPhotoUrl: url),
        'lease_document' => widget.tenant.copyWith(leaseDocumentUrl: url),
        _ => widget.tenant,
      };

      await ref
          .read(tenantControllerProvider.notifier)
          .updateTenant(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File uploaded successfully'),
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
    final tenant = widget.tenant;
    final theme = Theme.of(context);
    final paymentsAsync = ref.watch(tenantPaymentsProvider(tenant.id));

    // Determine property ID from unit
    final propertyId = _unit?.propertyId ?? '';
    final currencySymbol = 'FCFA'; // default, could derive from property

    return Scaffold(
      appBar: AppBar(
        title: Text(tenant.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => EditTenantScreen(tenant: tenant),
                ),
              );
              if (result == true) {
                ref.invalidate(tenantControllerProvider);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Tenant'),
                  content: Text(
                      'Remove "${tenant.fullName}"? This cannot be undone.'),
                  actions: [
                    TextButton(
                        onPressed: () => ctx.pop(false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => ctx.pop(true),
                        child: const Text('Delete',
                            style: TextStyle(color: AppColors.error))),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await ref
                    .read(tenantControllerProvider.notifier)
                    .deleteTenant(tenant.id);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: _uploading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Uploading file...'),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // --- Profile header ---
                _ProfileHeader(tenant: tenant, onUploadPhoto: () => _uploadFile('photo')),
                const SizedBox(height: 24),

                // --- Quick Actions ---
                Text('Quick Actions', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.payments_outlined,
                        label: 'Record\nPayment',
                        color: AppColors.success,
                        onTap: () async {
                          if (propertyId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Assign tenant to a unit first'),
                              ),
                            );
                            return;
                          }
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecordPaymentScreen(
                                tenant: tenant,
                                propertyId: propertyId,
                                currencySymbol: currencySymbol,
                              ),
                            ),
                          );
                          if (result == true) {
                            ref.invalidate(
                                tenantPaymentsProvider(tenant.id));
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.history,
                        label: 'Payment\nHistory',
                        color: theme.colorScheme.primary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentHistoryScreen(
                              tenantId: tenant.id,
                              tenantName: tenant.fullName,
                              currencySymbol: currencySymbol,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.edit_outlined,
                        label: 'Edit\nTenant',
                        color: theme.colorScheme.tertiary,
                        onTap: () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditTenantScreen(tenant: tenant),
                            ),
                          );
                          if (result == true) {
                            ref.invalidate(tenantControllerProvider);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- Lease & Financials ---
                Text('Lease & Financials',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.attach_money,
                          label: 'Rent',
                          value: tenant.rentAmount
                              .toCurrency(symbol: '$currencySymbol '),
                        ),
                        if (tenant.depositAmount != null)
                          _DetailRow(
                            icon: Icons.savings_outlined,
                            label: 'Deposit (Caution)',
                            value: tenant.depositAmount!
                                .toCurrency(symbol: '$currencySymbol '),
                          ),
                        _DetailRow(
                          icon: Icons.schedule_outlined,
                          label: 'Frequency',
                          value: PaymentFrequencies.label(
                              tenant.paymentFrequency),
                        ),
                        if (tenant.leaseStart != null)
                          _DetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Lease Start',
                            value: tenant.leaseStart!.formatted,
                          ),
                        if (tenant.leaseEnd != null)
                          _DetailRow(
                            icon: Icons.event_outlined,
                            label: 'Lease End',
                            value: tenant.leaseEnd!.formatted,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Recent Payments ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Payments',
                        style: theme.textTheme.titleMedium),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentHistoryScreen(
                            tenantId: tenant.id,
                            tenantName: tenant.fullName,
                            currencySymbol: currencySymbol,
                          ),
                        ),
                      ),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                paymentsAsync.when(
                  loading: () => const Center(
                      child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )),
                  error: (e, _) => Text('Could not load payments'),
                  data: (payments) {
                    if (payments.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No payments recorded yet',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    final recent = payments.take(5).toList();
                    return Column(
                      children: recent.map((p) => _RecentPaymentTile(
                        payment: p,
                        currencySymbol: currencySymbol,
                      )).toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // --- Contact Info ---
                Text('Contact Information',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (tenant.phone != null &&
                            tenant.phone!.isNotEmpty)
                          _DetailRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: tenant.phone!,
                          ),
                        if (tenant.email != null &&
                            tenant.email!.isNotEmpty)
                          _DetailRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: tenant.email!,
                          ),
                        if (tenant.idNumber != null &&
                            tenant.idNumber!.isNotEmpty)
                          _DetailRow(
                            icon: Icons.badge_outlined,
                            label: 'ID (CNI)',
                            value: tenant.idNumber!,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Unit info ---
                if (_unitLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_unit != null) ...[
                  Text('Assigned Unit',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.door_front_door_outlined,
                            label: 'Unit',
                            value: _unit!.unitLabel,
                          ),
                          _DetailRow(
                            icon: Icons.category_outlined,
                            label: 'Type',
                            value: UnitTypes.label(_unit!.unitType),
                          ),
                          _DetailRow(
                            icon: Icons.layers_outlined,
                            label: 'Floor',
                            value: '${_unit!.floorNumber}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // --- Documents ---
                Text('Documents & Files',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DocumentCard(
                        icon: Icons.badge_outlined,
                        label: 'ID Photo',
                        hasFile: tenant.idPhotoUrl != null,
                        onTap: () => _uploadFile('id_photo'),
                        url: tenant.idPhotoUrl,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DocumentCard(
                        icon: Icons.description_outlined,
                        label: 'Lease Contract',
                        hasFile: tenant.leaseDocumentUrl != null,
                        onTap: () => _uploadFile('lease_document'),
                        url: tenant.leaseDocumentUrl,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- Notes ---
                if (tenant.notes != null && tenant.notes!.isNotEmpty) ...[
                  Text('Notes', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(tenant.notes!,
                          style: theme.textTheme.bodyMedium),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                const SizedBox(height: 40),
              ],
            ),
    );
  }
}

// --- Sub-widgets ---

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.tenant, required this.onUploadPhoto});

  final Tenant tenant;
  final VoidCallback onUploadPhoto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onUploadPhoto,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: tenant.photoUrl != null
                      ? CachedNetworkImageProvider(tenant.photoUrl!)
                      : null,
                  child: tenant.photoUrl == null
                      ? Text(
                          tenant.fullName[0].toUpperCase(),
                          style: const TextStyle(fontSize: 36),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(tenant.fullName, style: theme.textTheme.headlineSmall),
          if (tenant.phone != null && tenant.phone!.isNotEmpty)
            Text(
              tenant.phone!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
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
          Icon(icon,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
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
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.icon,
    required this.label,
    required this.hasFile,
    required this.onTap,
    this.url,
  });

  final IconData icon;
  final String label;
  final bool hasFile;
  final VoidCallback onTap;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                hasFile ? Icons.check_circle : icon,
                color: hasFile ? AppColors.success : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(label, style: theme.textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(
                hasFile ? 'Tap to replace' : 'Tap to upload',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentPaymentTile extends StatelessWidget {
  const _RecentPaymentTile({
    required this.payment,
    required this.currencySymbol,
  });

  final Payment payment;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDeposit = payment.type == 'deposit';

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              isDeposit ? Icons.savings_outlined : Icons.receipt_long_outlined,
              size: 20,
              color: isDeposit
                  ? theme.colorScheme.tertiary
                  : theme.colorScheme.secondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.periodLabel ?? PaymentTypes.label(payment.type),
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(payment.date.formatted,
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Text(
              payment.amount.toCurrency(symbol: '$currencySymbol '),
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

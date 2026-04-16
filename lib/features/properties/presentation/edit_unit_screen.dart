import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/constants/app_colors.dart';
import 'package:landlord_os/core/extensions/l10n_ext.dart';
import 'package:landlord_os/core/utils/validators.dart';
import 'package:landlord_os/features/properties/domain/unit_model.dart';
import 'package:landlord_os/features/properties/presentation/unit_controller.dart';
import 'package:landlord_os/features/tenants/data/tenant_repository.dart';
import 'package:landlord_os/features/tenants/domain/tenant_model.dart';
import 'package:landlord_os/shared/widgets/app_button.dart';
import 'package:landlord_os/shared/widgets/app_text_field.dart';

/// Form to edit an existing unit.
class EditUnitScreen extends ConsumerStatefulWidget {
  const EditUnitScreen({required this.unit, super.key});

  final Unit unit;

  @override
  ConsumerState<EditUnitScreen> createState() => _EditUnitScreenState();
}

class _EditUnitScreenState extends ConsumerState<EditUnitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _unitLabelCtrl;
  late final TextEditingController _floorNumberCtrl;
  late final TextEditingController _bedroomsCtrl;
  late final TextEditingController _bathroomsCtrl;
  late final TextEditingController _sizeCtrl;
  late final TextEditingController _rentAmountCtrl;
  late final TextEditingController _notesCtrl;

  late String _unitType;
  bool _isSubmitting = false;
  XFile? _pickedPhoto;

  // Tenant assignment
  List<Tenant> _allTenants = [];
  String? _assignedTenantId;
  String? _originalTenantId;
  bool _tenantsLoading = true;

  @override
  void initState() {
    super.initState();
    final u = widget.unit;
    _unitLabelCtrl = TextEditingController(text: u.unitLabel);
    _floorNumberCtrl = TextEditingController(text: u.floorNumber.toString());
    _bedroomsCtrl = TextEditingController(text: u.bedrooms?.toString() ?? '');
    _bathroomsCtrl = TextEditingController(text: u.bathrooms?.toString() ?? '');
    _sizeCtrl = TextEditingController(text: u.sizeSqm?.toString() ?? '');
    _rentAmountCtrl = TextEditingController(
      text: u.rentAmount.toStringAsFixed(0),
    );
    _notesCtrl = TextEditingController(text: u.notes ?? '');
    _unitType = u.unitType;
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    try {
      final tenants = await ref.read(tenantRepositoryProvider).getAll();
      // Find if any tenant is currently assigned to this unit
      final currentTenant = tenants.where((t) => t.unitId == widget.unit.id).firstOrNull;
      if (mounted) {
        setState(() {
          _allTenants = tenants;
          _assignedTenantId = currentTenant?.id;
          _originalTenantId = currentTenant?.id;
          _tenantsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _tenantsLoading = false);
    }
  }

  @override
  void dispose() {
    _unitLabelCtrl.dispose();
    _floorNumberCtrl.dispose();
    _bedroomsCtrl.dispose();
    _bathroomsCtrl.dispose();
    _sizeCtrl.dispose();
    _rentAmountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
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
    if (file != null) setState(() => _pickedPhoto = file);
  }

  Future<String?> _uploadPhoto() async {
    if (_pickedPhoto == null) return widget.unit.photoUrl;
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser!.id;
    final ext = _pickedPhoto!.path.split('.').last;
    final path =
        '$userId/${widget.unit.id}/unit_${DateTime.now().millisecondsSinceEpoch}.$ext';

    await client.storage
        .from('property-files')
        .upload(
          path,
          File(_pickedPhoto!.path),
          fileOptions: const FileOptions(upsert: true),
        );
    return client.storage.from('property-files').getPublicUrl(path);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final photoUrl = await _uploadPhoto();
      final tenantRepo = ref.read(tenantRepositoryProvider);
      final tenantChanged = _assignedTenantId != _originalTenantId;

      final updated = widget.unit.copyWith(
        unitLabel: _unitLabelCtrl.text.trim(),
        floorNumber: int.tryParse(_floorNumberCtrl.text.trim()) ?? 0,
        unitType: _unitType,
        bedrooms: int.tryParse(_bedroomsCtrl.text.trim()),
        bathrooms: int.tryParse(_bathroomsCtrl.text.trim()),
        sizeSqm: double.tryParse(_sizeCtrl.text.trim()),
        rentAmount: double.tryParse(_rentAmountCtrl.text.trim()) ?? 0,
        photoUrl: photoUrl,
        isOccupied: _assignedTenantId != null,
        notes: _notesCtrl.text.trim().isNotEmpty
            ? _notesCtrl.text.trim()
            : null,
      );

      await ref
          .read(unitControllerProvider(widget.unit.propertyId).notifier)
          .updateUnit(updated);

      // Update tenant assignments if changed
      if (tenantChanged) {
        // Unassign the old tenant from this unit
        if (_originalTenantId != null) {
          final oldTenant = _allTenants.where((t) => t.id == _originalTenantId).firstOrNull;
          if (oldTenant != null) {
            await tenantRepo.update(oldTenant.copyWith(unitId: null));
          }
        }
        // Assign the new tenant to this unit
        if (_assignedTenantId != null) {
          final newTenant = _allTenants.where((t) => t.id == _assignedTenantId).firstOrNull;
          if (newTenant != null) {
            await tenantRepo.update(newTenant.copyWith(unitId: widget.unit.id));
          }
        }
      }

      if (mounted) context.pop(true);
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
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.editUnit)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Photo ---
              Text('Unit Photo', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                    image: _pickedPhoto != null
                        ? DecorationImage(
                            image: FileImage(File(_pickedPhoto!.path)),
                            fit: BoxFit.cover,
                          )
                        : widget.unit.photoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(widget.unit.photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (_pickedPhoto == null && widget.unit.photoUrl == null)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                              'Tap to add a photo',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              AppTextField(
                label: context.l10n.unitLabel,
                controller: _unitLabelCtrl,
                validator: Validators.required,
                prefixIcon: Icons.door_front_door_outlined,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _unitType,
                decoration: InputDecoration(
                  labelText: context.l10n.unitType,
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                items: UnitTypes.all
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(UnitTypes.label(type)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _unitType = v);
                },
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: context.l10n.floorNumber,
                controller: _floorNumberCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.layers_outlined,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: context.l10n.bedrooms,
                      controller: _bedroomsCtrl,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.bed_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: context.l10n.bathrooms,
                      controller: _bathroomsCtrl,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.bathtub_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: context.l10n.size,
                controller: _sizeCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.square_foot_outlined,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: context.l10n.rentAmount,
                controller: _rentAmountCtrl,
                validator: Validators.positiveNumber,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.attach_money,
              ),
              const SizedBox(height: 16),

              AppTextField(label: context.l10n.notes, controller: _notesCtrl, maxLines: 3),
              const SizedBox(height: 20),

              // --- Tenant assignment ---
              Text(context.l10n.selectTenant, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              if (_tenantsLoading)
                const LinearProgressIndicator()
              else
                DropdownButtonFormField<String?>(
                  initialValue: _assignedTenantId,
                  decoration: InputDecoration(
                    labelText: context.l10n.selectTenant,
                    prefixIcon: const Icon(Icons.person_outlined),
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(context.l10n.vacant),
                    ),
                    ..._allTenants.map((t) => DropdownMenuItem<String?>(
                          value: t.id,
                          child: Text('${t.fullName}${t.phone != null ? " (${t.phone})" : ""}'),
                        )),
                  ],
                  onChanged: (v) => setState(() => _assignedTenantId = v),
                ),
              const SizedBox(height: 24),

              AppButton(
                label: context.l10n.save,
                onPressed: _submit,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

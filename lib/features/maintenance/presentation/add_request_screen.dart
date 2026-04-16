import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/constants/app_colors.dart';
import 'package:landlord_os/core/extensions/l10n_ext.dart';
import 'package:landlord_os/core/utils/validators.dart';
import 'package:landlord_os/features/maintenance/domain/maintenance_request_model.dart';
import 'package:landlord_os/features/maintenance/presentation/maintenance_controller.dart';
import 'package:landlord_os/features/properties/data/unit_repository.dart';
import 'package:landlord_os/features/properties/domain/unit_model.dart';
import 'package:landlord_os/features/properties/presentation/property_controller.dart';
import 'package:landlord_os/shared/widgets/app_button.dart';
import 'package:landlord_os/shared/widgets/app_text_field.dart';

/// Form to create a new maintenance request.
class AddRequestScreen extends ConsumerStatefulWidget {
  const AddRequestScreen({this.propertyId, this.unitId, super.key});

  final String? propertyId;
  final String? unitId;

  @override
  ConsumerState<AddRequestScreen> createState() => _AddRequestScreenState();
}

class _AddRequestScreenState extends ConsumerState<AddRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _priority = 'medium';
  String? _selectedPropertyId;
  String? _selectedUnitId;
  bool _isSubmitting = false;

  List<Unit> _units = [];
  bool _unitsLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedPropertyId = widget.propertyId;
    _selectedUnitId = widget.unitId;
    if (_selectedPropertyId != null) {
      _loadUnitsForProperty(_selectedPropertyId!);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUnitsForProperty(String propertyId) async {
    setState(() => _unitsLoading = true);
    try {
      final units = await ref
          .read(unitRepositoryProvider)
          .getByProperty(propertyId);
      if (mounted) {
        setState(() {
          _units = units;
          _unitsLoading = false;
          // Clear unit selection if it doesn't belong to this property.
          if (_selectedUnitId != null &&
              !units.any((u) => u.id == _selectedUnitId)) {
            _selectedUnitId = null;
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _unitsLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPropertyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a property.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final request = MaintenanceRequest(
      id: '',
      landlordId: Supabase.instance.client.auth.currentUser!.id,
      propertyId: _selectedPropertyId!,
      unitId: _selectedUnitId,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isNotEmpty
          ? _descCtrl.text.trim()
          : null,
      priority: _priority,
    );

    try {
      await ref
          .read(maintenanceControllerProvider.notifier)
          .addRequest(request);
      if (mounted) context.pop();
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
    final propertiesAsync = ref.watch(propertyControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.addRequest)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              AppTextField(
                label: context.l10n.title,
                controller: _titleCtrl,
                validator: Validators.required,
                prefixIcon: Icons.title,
              ),
              const SizedBox(height: 16),

              // Description
              AppTextField(
                label: context.l10n.description,
                controller: _descCtrl,
                maxLines: 4,
                prefixIcon: Icons.notes_outlined,
              ),
              const SizedBox(height: 16),

              // Priority dropdown
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: InputDecoration(
                  labelText: context.l10n.priority,
                  prefixIcon: const Icon(Icons.flag_outlined),
                ),
                items: MaintenancePriorities.all
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(MaintenancePriorities.label(p)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _priority = v);
                },
              ),
              const SizedBox(height: 16),

              // Property dropdown
              propertiesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => Text(
                  'Could not load properties',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                data: (properties) => DropdownButtonFormField<String>(
                  initialValue: _selectedPropertyId,
                  decoration: const InputDecoration(
                    labelText: 'Property',
                    prefixIcon: Icon(Icons.home_work_outlined),
                  ),
                  items: properties
                      .map(
                        (p) =>
                            DropdownMenuItem(value: p.id, child: Text(p.name)),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedPropertyId = v;
                      _selectedUnitId = null;
                      _units = [];
                    });
                    if (v != null) _loadUnitsForProperty(v);
                  },
                  validator: (v) =>
                      v == null ? 'Please select a property.' : null,
                ),
              ),
              const SizedBox(height: 16),

              // Unit dropdown (optional)
              if (_unitsLoading)
                const LinearProgressIndicator()
              else if (_units.isNotEmpty)
                DropdownButtonFormField<String>(
                  initialValue: _selectedUnitId,
                  decoration: const InputDecoration(
                    labelText: 'Unit (optional)',
                    prefixIcon: Icon(Icons.door_front_door_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('None'),
                    ),
                    ..._units.map(
                      (u) => DropdownMenuItem(
                        value: u.id,
                        child: Text(u.unitLabel),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedUnitId = v),
                ),
              const SizedBox(height: 24),

              // Submit button
              AppButton(
                label: context.l10n.addRequest,
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

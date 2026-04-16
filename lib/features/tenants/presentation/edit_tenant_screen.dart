import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:landlord_os/core/constants/app_colors.dart';
import 'package:landlord_os/core/extensions/l10n_ext.dart';
import 'package:landlord_os/core/utils/validators.dart';
import 'package:landlord_os/features/properties/data/unit_repository.dart';
import 'package:landlord_os/features/properties/domain/unit_model.dart';
import 'package:landlord_os/features/tenants/domain/tenant_model.dart';
import 'package:landlord_os/features/tenants/presentation/tenant_controller.dart';
import 'package:landlord_os/shared/widgets/app_button.dart';
import 'package:landlord_os/shared/widgets/app_text_field.dart';

/// Form to edit an existing tenant.
class EditTenantScreen extends ConsumerStatefulWidget {
  const EditTenantScreen({required this.tenant, super.key});

  final Tenant tenant;

  @override
  ConsumerState<EditTenantScreen> createState() => _EditTenantScreenState();
}

class _EditTenantScreenState extends ConsumerState<EditTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _idNumberCtrl;
  late final TextEditingController _rentCtrl;
  late final TextEditingController _depositCtrl;
  late final TextEditingController _notesCtrl;

  late String? _selectedUnitId;
  late String _paymentFrequency;
  DateTime? _leaseStart;
  DateTime? _leaseEnd;
  bool _isSubmitting = false;
  List<Unit>? _units;
  bool _unitsLoading = true;
  String? _unitsError;

  @override
  void initState() {
    super.initState();
    final t = widget.tenant;
    _nameCtrl = TextEditingController(text: t.fullName);
    _emailCtrl = TextEditingController(text: t.email ?? '');
    _phoneCtrl = TextEditingController(text: t.phone ?? '');
    _idNumberCtrl = TextEditingController(text: t.idNumber ?? '');
    _rentCtrl = TextEditingController(text: t.rentAmount.toStringAsFixed(0));
    _depositCtrl = TextEditingController(
        text: t.depositAmount?.toStringAsFixed(0) ?? '');
    _notesCtrl = TextEditingController(text: t.notes ?? '');
    _selectedUnitId = t.unitId;
    _paymentFrequency = t.paymentFrequency;
    _leaseStart = t.leaseStart;
    _leaseEnd = t.leaseEnd;
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    try {
      final units = await ref.read(unitRepositoryProvider).getAll();
      if (mounted) {
        setState(() {
          _units = units;
          _unitsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _unitsError = e.toString();
          _unitsLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _idNumberCtrl.dispose();
    _rentCtrl.dispose();
    _depositCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _leaseStart : _leaseEnd;
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _leaseStart = date;
        } else {
          _leaseEnd = date;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final tenant = widget.tenant.copyWith(
      fullName: _nameCtrl.text.trim(),
      email:
          _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      phone:
          _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      idNumber: _idNumberCtrl.text.trim().isNotEmpty
          ? _idNumberCtrl.text.trim()
          : null,
      unitId: _selectedUnitId,
      rentAmount: double.parse(_rentCtrl.text.trim()),
      depositAmount: double.tryParse(_depositCtrl.text.trim()),
      paymentFrequency: _paymentFrequency,
      leaseStart: _leaseStart,
      leaseEnd: _leaseEnd,
      notes:
          _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    );

    try {
      await ref.read(tenantControllerProvider.notifier).updateTenant(tenant);
      if (mounted) context.pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatDate(DateTime? d) =>
      d == null ? 'Not set' : '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.editTenant)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: context.l10n.fullName,
                controller: _nameCtrl,
                validator: Validators.required,
                prefixIcon: Icons.person_outlined,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: context.l10n.phone,
                controller: _phoneCtrl,
                validator: Validators.phone,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                hint: 'e.g. +237 6 70 00 00 00',
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: context.l10n.email,
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: context.l10n.idNumber,
                controller: _idNumberCtrl,
                prefixIcon: Icons.badge_outlined,
              ),
              const SizedBox(height: 16),

              // Unit dropdown
              if (_unitsLoading)
                const LinearProgressIndicator()
              else if (_unitsError != null)
                Text('Could not load units',
                    style: TextStyle(color: theme.colorScheme.error))
              else
                DropdownButtonFormField<String>(
                  initialValue: _selectedUnitId,
                  decoration: InputDecoration(
                    labelText: context.l10n.selectUnit,
                    prefixIcon: const Icon(Icons.door_front_door_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                        value: null, child: Text('Unassigned')),
                    if (_units != null)
                      ..._units!.map((u) => DropdownMenuItem(
                            value: u.id,
                            child: Text(u.unitLabel),
                          )),
                  ],
                  onChanged: (v) => setState(() => _selectedUnitId = v),
                ),
              const SizedBox(height: 16),

              // Payment frequency dropdown
              DropdownButtonFormField<String>(
                initialValue: _paymentFrequency,
                decoration: InputDecoration(
                  labelText: context.l10n.paymentFrequency,
                  prefixIcon: const Icon(Icons.schedule_outlined),
                ),
                items: PaymentFrequencies.all
                    .map((freq) => DropdownMenuItem(
                          value: freq,
                          child: Text(PaymentFrequencies.label(freq)),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _paymentFrequency = v);
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: context.l10n.rentAmount,
                      controller: _rentCtrl,
                      validator: Validators.positiveNumber,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: context.l10n.deposit,
                      controller: _depositCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Lease dates
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(isStart: true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: context.l10n.leaseStart,
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(_formatDate(_leaseStart)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(isStart: false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: context.l10n.leaseEnd,
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(_formatDate(_leaseEnd)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: context.l10n.notes,
                controller: _notesCtrl,
                maxLines: 3,
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

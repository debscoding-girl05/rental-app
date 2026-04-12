import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/constants/app_colors.dart';
import 'package:landlord_os/core/utils/validators.dart';
import 'package:landlord_os/features/properties/presentation/property_controller.dart';
import 'package:landlord_os/features/tenants/domain/tenant_model.dart';
import 'package:landlord_os/features/tenants/presentation/tenant_controller.dart';
import 'package:landlord_os/shared/widgets/app_button.dart';
import 'package:landlord_os/shared/widgets/app_text_field.dart';

/// Form to add a new tenant.
class AddTenantScreen extends ConsumerStatefulWidget {
  const AddTenantScreen({super.key});

  @override
  ConsumerState<AddTenantScreen> createState() => _AddTenantScreenState();
}

class _AddTenantScreenState extends ConsumerState<AddTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();

  String? _selectedPropertyId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _rentCtrl.dispose();
    _depositCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final tenant = Tenant(
      id: '',
      landlordId: Supabase.instance.client.auth.currentUser!.id,
      propertyId: _selectedPropertyId,
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      phone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      rentAmount: double.parse(_rentCtrl.text.trim()),
      depositAmount: double.tryParse(_depositCtrl.text.trim()),
    );

    try {
      await ref.read(tenantControllerProvider.notifier).addTenant(tenant);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
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
      appBar: AppBar(title: const Text('Add Tenant')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(label: 'Full Name', controller: _nameCtrl, validator: Validators.required, prefixIcon: Icons.person_outlined),
              const SizedBox(height: 16),
              AppTextField(label: 'Email', controller: _emailCtrl, validator: Validators.email, keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined),
              const SizedBox(height: 16),
              AppTextField(label: 'Phone', controller: _phoneCtrl, validator: Validators.phone, keyboardType: TextInputType.phone, prefixIcon: Icons.phone_outlined),
              const SizedBox(height: 16),

              // Property dropdown
              propertiesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Could not load properties'),
                data: (properties) => DropdownButtonFormField<String>(
                  initialValue: _selectedPropertyId,
                  decoration: const InputDecoration(
                    labelText: 'Assign to Property',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Unassigned')),
                    ...properties.map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name),
                        )),
                  ],
                  onChanged: (v) => setState(() => _selectedPropertyId = v),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: AppTextField(label: 'Monthly Rent', controller: _rentCtrl, validator: Validators.positiveNumber, keyboardType: TextInputType.number, prefixIcon: Icons.attach_money)),
                  const SizedBox(width: 12),
                  Expanded(child: AppTextField(label: 'Deposit', controller: _depositCtrl, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 24),
              AppButton(label: 'Add Tenant', onPressed: _submit, isLoading: _isSubmitting),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/constants/app_colors.dart';
import 'package:landlord_os/core/utils/validators.dart';
import 'package:landlord_os/features/properties/domain/property_model.dart';
import 'package:landlord_os/features/properties/presentation/property_controller.dart';
import 'package:landlord_os/shared/widgets/app_button.dart';
import 'package:landlord_os/shared/widgets/app_text_field.dart';

/// Form to add a new property.
class AddPropertyScreen extends ConsumerStatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  ConsumerState<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _bedroomsCtrl = TextEditingController();
  final _bathroomsCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _purchasePriceCtrl = TextEditingController();
  final _mortgageCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _bedroomsCtrl.dispose();
    _bathroomsCtrl.dispose();
    _sizeCtrl.dispose();
    _purchasePriceCtrl.dispose();
    _mortgageCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final property = Property(
      id: '',
      landlordId: Supabase.instance.client.auth.currentUser!.id,
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      bedrooms: int.tryParse(_bedroomsCtrl.text.trim()),
      bathrooms: int.tryParse(_bathroomsCtrl.text.trim()),
      sizeSqm: double.tryParse(_sizeCtrl.text.trim()),
      purchasePrice: double.tryParse(_purchasePriceCtrl.text.trim()),
      mortgageMonthly: double.tryParse(_mortgageCtrl.text.trim()),
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    );

    try {
      await ref.read(propertyControllerProvider.notifier).addProperty(property);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Add Property')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(label: 'Property Name', controller: _nameCtrl, validator: Validators.required, prefixIcon: Icons.home_outlined),
              const SizedBox(height: 16),
              AppTextField(label: 'Address', controller: _addressCtrl, validator: Validators.required, prefixIcon: Icons.location_on_outlined),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: AppTextField(label: 'City', controller: _cityCtrl, validator: Validators.required)),
                  const SizedBox(width: 12),
                  Expanded(child: AppTextField(label: 'Country', controller: _countryCtrl, validator: Validators.required)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: AppTextField(label: 'Bedrooms', controller: _bedroomsCtrl, keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: AppTextField(label: 'Bathrooms', controller: _bathroomsCtrl, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(label: 'Size (sqm)', controller: _sizeCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              AppTextField(label: 'Purchase Price', controller: _purchasePriceCtrl, keyboardType: TextInputType.number, prefixIcon: Icons.attach_money),
              const SizedBox(height: 16),
              AppTextField(label: 'Monthly Mortgage', controller: _mortgageCtrl, keyboardType: TextInputType.number, prefixIcon: Icons.account_balance_outlined),
              const SizedBox(height: 16),
              AppTextField(label: 'Notes', controller: _notesCtrl, maxLines: 3),
              const SizedBox(height: 24),
              AppButton(label: 'Add Property', onPressed: _submit, isLoading: _isSubmitting),
            ],
          ),
        ),
      ),
    );
  }
}

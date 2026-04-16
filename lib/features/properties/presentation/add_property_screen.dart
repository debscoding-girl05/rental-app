import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/constants/app_colors.dart';
import 'package:landlord_os/core/constants/currencies.dart';
import 'package:landlord_os/core/extensions/l10n_ext.dart';
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
  final _quartierCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _floorsCtrl = TextEditingController(text: '1');
  final _totalUnitsCtrl = TextEditingController(text: '1');
  final _purchasePriceCtrl = TextEditingController();
  final _mortgageCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _propertyType = PropertyTypes.all.first;
  String _currency = 'XOF';
  bool _isSubmitting = false;

  // Photos picked before creation
  final List<XFile> _pickedPhotos = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _quartierCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _floorsCtrl.dispose();
    _totalUnitsCtrl.dispose();
    _purchasePriceCtrl.dispose();
    _mortgageCtrl.dispose();
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
    final file = await picker.pickImage(source: source, maxWidth: 1400);
    if (file != null) {
      setState(() => _pickedPhotos.add(file));
    }
  }

  Future<List<String>> _uploadPhotos(String propertyId) async {
    if (_pickedPhotos.isEmpty) return [];
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser!.id;
    final urls = <String>[];

    for (final file in _pickedPhotos) {
      final ext = file.path.split('.').last;
      final path =
          '$userId/$propertyId/property_${DateTime.now().millisecondsSinceEpoch}_${urls.length}.$ext';
      await client.storage
          .from('property-files')
          .upload(
            path,
            File(file.path),
            fileOptions: const FileOptions(upsert: true),
          );
      urls.add(client.storage.from('property-files').getPublicUrl(path));
    }
    return urls;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final property = Property(
      id: '',
      landlordId: Supabase.instance.client.auth.currentUser!.id,
      name: _nameCtrl.text.trim(),
      propertyType: _propertyType,
      address: _addressCtrl.text.trim(),
      quartier: _quartierCtrl.text.trim().isNotEmpty
          ? _quartierCtrl.text.trim()
          : null,
      city: _cityCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      floors: int.tryParse(_floorsCtrl.text.trim()) ?? 1,
      totalUnits: int.tryParse(_totalUnitsCtrl.text.trim()) ?? 1,
      currency: _currency,
      purchasePrice: double.tryParse(_purchasePriceCtrl.text.trim()),
      mortgageMonthly: double.tryParse(_mortgageCtrl.text.trim()),
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    );

    try {
      await ref.read(propertyControllerProvider.notifier).addProperty(property);

      // Upload photos if any were picked
      if (_pickedPhotos.isNotEmpty) {
        // Get the newly created property (last in list after refresh)
        final props = await ref.read(propertyControllerProvider.future);
        final created = props.firstWhere((p) => p.name == property.name);
        final urls = await _uploadPhotos(created.id);
        if (urls.isNotEmpty) {
          await ref
              .read(propertyControllerProvider.notifier)
              .updateProperty(created.copyWith(photos: urls));
        }
      }

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
    final theme = Theme.of(context);
    final currencySymbol = Currencies.fromCode(_currency).symbol;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.addProperty)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Photo picker ---
              Text('Photos', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._pickedPhotos.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(entry.value.path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _pickedPhotos.removeAt(entry.key),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: _pickPhoto,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.05,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              AppTextField(
                label: context.l10n.propertyName,
                controller: _nameCtrl,
                validator: Validators.required,
                prefixIcon: Icons.home_outlined,
              ),
              const SizedBox(height: 16),

              // Property type dropdown
              DropdownButtonFormField<String>(
                initialValue: _propertyType,
                decoration: InputDecoration(
                  labelText: context.l10n.propertyType,
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                items: PropertyTypes.all
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(PropertyTypes.label(type)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _propertyType = v);
                },
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: context.l10n.address,
                controller: _addressCtrl,
                validator: Validators.required,
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: context.l10n.quartier,
                controller: _quartierCtrl,
                prefixIcon: Icons.map_outlined,
                hint: 'e.g. Plateau, Cocody, Yoff',
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: context.l10n.city,
                      controller: _cityCtrl,
                      validator: Validators.required,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: context.l10n.country,
                      controller: _countryCtrl,
                      validator: Validators.required,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: context.l10n.floors,
                      controller: _floorsCtrl,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.layers_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: context.l10n.numberOfUnits,
                      controller: _totalUnitsCtrl,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.door_front_door_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Currency dropdown
              DropdownButtonFormField<String>(
                initialValue: _currency,
                decoration: InputDecoration(
                  labelText: context.l10n.currency,
                  prefixIcon: const Icon(Icons.monetization_on_outlined),
                ),
                items: Currencies.all
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.code,
                        child: Text('${c.code} - ${c.name}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _currency = v);
                },
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: '${context.l10n.purchasePrice} ($currencySymbol)',
                controller: _purchasePriceCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.attach_money,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: '${context.l10n.mortgage} ($currencySymbol)',
                controller: _mortgageCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.account_balance_outlined,
              ),
              const SizedBox(height: 16),

              AppTextField(label: context.l10n.notes, controller: _notesCtrl, maxLines: 3),
              const SizedBox(height: 24),

              AppButton(
                label: _pickedPhotos.isEmpty
                    ? context.l10n.addProperty
                    : '${context.l10n.addProperty} (${_pickedPhotos.length} photos)',
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

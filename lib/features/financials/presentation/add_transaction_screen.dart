import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/constants/app_colors.dart';
import 'package:landlord_os/core/extensions/l10n_ext.dart';
import 'package:landlord_os/core/utils/validators.dart';
import 'package:landlord_os/features/financials/domain/transaction_model.dart';
import 'package:landlord_os/features/financials/presentation/financials_controller.dart';
import 'package:landlord_os/features/properties/data/unit_repository.dart';
import 'package:landlord_os/features/properties/domain/unit_model.dart';
import 'package:landlord_os/features/properties/presentation/property_controller.dart';
import 'package:landlord_os/shared/widgets/app_button.dart';
import 'package:landlord_os/shared/widgets/app_text_field.dart';

/// Form to add a new financial transaction.
class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  String _type = 'income';
  String _category = 'rent';
  String? _selectedPropertyId;
  String? _selectedUnitId;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  List<Unit> _unitsForProperty = [];
  bool _unitsLoading = false;

  static const _incomeCategories = ['rent', 'deposit', 'other_income'];
  static const _expenseCategories = [
    'maintenance',
    'insurance',
    'tax',
    'mortgage',
    'utilities',
    'management_fee',
    'other_expense',
  ];

  List<String> get _categories =>
      _type == 'income' ? _incomeCategories : _expenseCategories;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUnitsForProperty(String propertyId) async {
    setState(() {
      _unitsLoading = true;
      _selectedUnitId = null;
      _unitsForProperty = [];
    });

    try {
      final units =
          await ref.read(unitRepositoryProvider).getByProperty(propertyId);
      if (mounted) {
        setState(() {
          _unitsForProperty = units;
          _unitsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _unitsForProperty = [];
          _unitsLoading = false;
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPropertyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a property.'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final tx = Transaction(
      id: '',
      landlordId: Supabase.instance.client.auth.currentUser!.id,
      propertyId: _selectedPropertyId!,
      type: _type,
      category: _category,
      amount: double.parse(_amountCtrl.text.trim()),
      date: _selectedDate,
      description: _descriptionCtrl.text.trim().isNotEmpty
          ? _descriptionCtrl.text.trim()
          : null,
    );

    try {
      await ref
          .read(financialsControllerProvider.notifier)
          .addTransaction(tx);
      if (mounted) context.pop();
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

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(propertyControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.addTransaction)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type toggle
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                      value: 'income',
                      label: Text(context.l10n.income),
                      icon: const Icon(Icons.arrow_downward)),
                  ButtonSegment(
                      value: 'expense',
                      label: Text(context.l10n.expense),
                      icon: const Icon(Icons.arrow_upward)),
                ],
                selected: {_type},
                onSelectionChanged: (v) {
                  setState(() {
                    _type = v.first;
                    _category = _categories.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Property dropdown
              propertiesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Could not load properties'),
                data: (properties) => DropdownButtonFormField<String>(
                  initialValue: _selectedPropertyId,
                  decoration: const InputDecoration(
                    labelText: 'Property',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                  items: properties
                      .map((p) => DropdownMenuItem(
                          value: p.id, child: Text(p.name)))
                      .toList(),
                  onChanged: (v) {
                    setState(() => _selectedPropertyId = v);
                    if (v != null) _loadUnitsForProperty(v);
                  },
                  validator: (v) =>
                      v == null ? 'Select a property' : null,
                ),
              ),
              const SizedBox(height: 16),

              // Unit dropdown (optional, loads after property is selected)
              if (_selectedPropertyId != null) ...[
                if (_unitsLoading)
                  const LinearProgressIndicator()
                else if (_unitsForProperty.isNotEmpty)
                  DropdownButtonFormField<String>(
                    initialValue: _selectedUnitId,
                    decoration: const InputDecoration(
                      labelText: 'Unit (optional)',
                      prefixIcon: Icon(Icons.door_front_door_outlined),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                          value: null, child: Text('All units / General')),
                      ..._unitsForProperty.map((u) => DropdownMenuItem(
                            value: u.id,
                            child: Text(u.unitLabel),
                          )),
                    ],
                    onChanged: (v) =>
                        setState(() => _selectedUnitId = v),
                  ),
                const SizedBox(height: 16),
              ],

              // Category dropdown
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: context.l10n.category,
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child:
                              Text(c.replaceAll('_', ' ').toUpperCase()),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _category = v);
                },
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: context.l10n.amount,
                controller: _amountCtrl,
                validator: Validators.positiveNumber,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.attach_money,
              ),
              const SizedBox(height: 16),

              // Date picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(context.l10n.date),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: TextButton(
                  onPressed: _pickDate,
                  child: const Text('Change'),
                ),
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: context.l10n.description,
                controller: _descriptionCtrl,
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              AppButton(
                label: context.l10n.addTransaction,
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

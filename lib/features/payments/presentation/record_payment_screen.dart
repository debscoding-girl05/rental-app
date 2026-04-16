import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/constants/app_colors.dart';
import 'package:landlord_os/core/extensions/l10n_ext.dart';
import 'package:landlord_os/core/extensions/datetime_ext.dart';
import 'package:landlord_os/core/extensions/num_ext.dart';
import 'package:landlord_os/features/payments/domain/payment_model.dart';
import 'package:landlord_os/features/payments/presentation/payment_controller.dart';
import 'package:landlord_os/features/tenants/domain/tenant_model.dart';

/// Quick payment recording screen.
class RecordPaymentScreen extends ConsumerStatefulWidget {
  const RecordPaymentScreen({
    required this.tenant,
    required this.propertyId,
    required this.currencySymbol,
    super.key,
  });

  final Tenant tenant;
  final String propertyId;
  final String currencySymbol;

  @override
  ConsumerState<RecordPaymentScreen> createState() =>
      _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends ConsumerState<RecordPaymentScreen> {
  String _type = 'rent';
  String _paymentMethod = 'cash';
  late final TextEditingController _amountCtrl;
  late final TextEditingController _notesCtrl;
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.tenant.rentAmount.toStringAsFixed(0),
    );
    _notesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (date != null) setState(() => _date = date);
  }

  String _periodLabel() {
    const months = [
      '',
      'Janvier',
      'Fevrier',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Aout',
      'Septembre',
      'Octobre',
      'Novembre',
      'Decembre',
    ];
    return '${months[_date.month]} ${_date.year}';
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    setState(() => _isSubmitting = true);

    final payment = Payment(
      id: '',
      landlordId: Supabase.instance.client.auth.currentUser!.id,
      tenantId: widget.tenant.id,
      propertyId: widget.propertyId,
      unitId: widget.tenant.unitId,
      type: _type,
      amount: amount,
      currency: 'XOF',
      date: _date,
      periodLabel: _type == 'rent' ? _periodLabel() : null,
      paymentMethod: _paymentMethod,
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    );

    try {
      await ref.read(paymentControllerProvider.notifier).addPayment(payment);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${PaymentTypes.label(_type)} recorded: ${amount.toCurrency(symbol: '${widget.currencySymbol} ')}',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(true);
      }
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
    final cs = widget.currencySymbol;

    return Scaffold(
      appBar: AppBar(title: const Text('Record Payment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tenant info header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    child: Text(
                      widget.tenant.fullName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tenant.fullName,
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          'Rent: $cs ${widget.tenant.rentAmount.toCurrency(symbol: '')}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Payment type chips
          Text('Type', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: PaymentTypes.all.map((type) {
              final selected = _type == type;
              return ChoiceChip(
                label: Text(PaymentTypes.label(type)),
                selected: selected,
                onSelected: (_) => setState(() => _type = type),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Amount
          TextFormField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            style: theme.textTheme.headlineMedium,
            decoration: InputDecoration(
              labelText: context.l10n.amount,
              prefixText: '$cs ',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // Date picker
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: context.l10n.date,
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                border: const OutlineInputBorder(),
              ),
              child: Text(_date.formatted),
            ),
          ),
          const SizedBox(height: 20),

          // Payment method chips
          Text('Payment Method', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: PaymentMethods.all.map((method) {
              final selected = _paymentMethod == method;
              return ChoiceChip(
                label: Text(PaymentMethods.label(method)),
                selected: selected,
                onSelected: (_) => setState(() => _paymentMethod = method),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Notes
          TextFormField(
            controller: _notesCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: context.l10n.notes,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          // Submit
          FilledButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(_isSubmitting ? 'Recording...' : 'Confirm Payment'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }
}

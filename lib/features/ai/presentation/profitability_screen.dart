import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:landlord_os/core/constants/app_colors.dart';
import 'package:landlord_os/core/extensions/num_ext.dart';
import 'package:landlord_os/core/utils/validators.dart';
import 'package:landlord_os/features/ai/domain/profitability_report.dart';
import 'package:landlord_os/features/ai/presentation/ai_controller.dart';
import 'package:landlord_os/shared/widgets/app_button.dart';
import 'package:landlord_os/shared/widgets/app_text_field.dart';

/// AI-powered profitability analysis screen.
class ProfitabilityScreen extends ConsumerStatefulWidget {
  const ProfitabilityScreen({super.key});

  @override
  ConsumerState<ProfitabilityScreen> createState() =>
      _ProfitabilityScreenState();
}

class _ProfitabilityScreenState extends ConsumerState<ProfitabilityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _purchasePriceCtrl = TextEditingController();
  final _mortgageCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  final _expensesCtrl = TextEditingController();

  bool _isLoading = false;
  ProfitabilityReport? _result;

  @override
  void dispose() {
    _purchasePriceCtrl.dispose();
    _mortgageCtrl.dispose();
    _rentCtrl.dispose();
    _expensesCtrl.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final report = await ref
          .read(aiControllerProvider.notifier)
          .analyzeProfitability(
            purchasePrice: double.parse(_purchasePriceCtrl.text.trim()),
            mortgageMonthly: double.parse(_mortgageCtrl.text.trim()),
            monthlyRent: double.parse(_rentCtrl.text.trim()),
            monthlyExpenses: double.parse(_expensesCtrl.text.trim()),
          );
      if (mounted) setState(() => _result = report);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profitability Analysis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                      label: 'Purchase Price',
                      controller: _purchasePriceCtrl,
                      validator: Validators.positiveNumber,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.home),
                  const SizedBox(height: 16),
                  AppTextField(
                      label: 'Monthly Mortgage',
                      controller: _mortgageCtrl,
                      validator: Validators.positiveNumber,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.account_balance),
                  const SizedBox(height: 16),
                  AppTextField(
                      label: 'Monthly Rent Income',
                      controller: _rentCtrl,
                      validator: Validators.positiveNumber,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money),
                  const SizedBox(height: 16),
                  AppTextField(
                      label: 'Monthly Expenses (maintenance, insurance, tax)',
                      controller: _expensesCtrl,
                      validator: Validators.positiveNumber,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.money_off),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Analyze Profitability',
                    onPressed: _analyze,
                    isLoading: _isLoading,
                    icon: Icons.analytics,
                  ),
                ],
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Analysis Results', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 16),
                      _MetricRow(label: 'Gross Yield', value: _result!.grossYield.toPercentage()),
                      _MetricRow(label: 'Net Yield', value: _result!.netYield.toPercentage()),
                      _MetricRow(
                        label: 'Monthly Cash Flow',
                        value: _result!.monthlyCashFlow.toCurrency(),
                        valueColor: _result!.monthlyCashFlow >= 0 ? AppColors.success : AppColors.error,
                      ),
                      _MetricRow(label: 'Annual ROI', value: _result!.annualRoi.toPercentage()),
                      _MetricRow(label: 'Break-even', value: _result!.breakEvenTimeline),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text('Verdict', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(_result!.verdict, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              )),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

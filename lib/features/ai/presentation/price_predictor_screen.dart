import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:landlord_os/core/constants/app_colors.dart';
import 'package:landlord_os/core/extensions/l10n_ext.dart';
import 'package:landlord_os/core/extensions/num_ext.dart';
import 'package:landlord_os/core/providers/currency_provider.dart';
import 'package:landlord_os/core/utils/validators.dart';
import 'package:landlord_os/features/ai/domain/price_prediction.dart';
import 'package:landlord_os/features/ai/presentation/ai_controller.dart';
import 'package:landlord_os/shared/widgets/app_button.dart';
import 'package:landlord_os/shared/widgets/app_text_field.dart';

/// AI-powered rent price prediction screen.
class PricePredictorScreen extends ConsumerStatefulWidget {
  const PricePredictorScreen({super.key});

  @override
  ConsumerState<PricePredictorScreen> createState() =>
      _PricePredictorScreenState();
}

class _PricePredictorScreenState extends ConsumerState<PricePredictorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _bedroomsCtrl = TextEditingController();
  final _bathroomsCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _isLoading = false;
  PricePrediction? _result;

  @override
  void dispose() {
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _bedroomsCtrl.dispose();
    _bathroomsCtrl.dispose();
    _sizeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final prediction = await ref
          .read(aiControllerProvider.notifier)
          .predictPrice(
            city: _cityCtrl.text.trim(),
            country: _countryCtrl.text.trim(),
            bedrooms: int.tryParse(_bedroomsCtrl.text.trim()),
            bathrooms: int.tryParse(_bathroomsCtrl.text.trim()),
            sizeSqm: double.tryParse(_sizeCtrl.text.trim()),
            notes: _notesCtrl.text.trim().isNotEmpty
                ? _notesCtrl.text.trim()
                : null,
            currencySymbol: ref.read(currencyProvider).symbol,
            currencyCode: ref.read(currencyProvider).code,
          );
      if (mounted) setState(() => _result = prediction);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = ref.watch(currencyProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.pricePredictor)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'City',
                          controller: _cityCtrl,
                          validator: Validators.required,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Country',
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
                          label: 'Bedrooms',
                          controller: _bedroomsCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Bathrooms',
                          controller: _bathroomsCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Size (sqm)',
                    controller: _sizeCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: context.l10n.notes,
                    controller: _notesCtrl,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: context.l10n.predict,
                    onPressed: _predict,
                    isLoading: _isLoading,
                    icon: Icons.auto_awesome,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        context.l10n.estimatedPrice,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _result!.suggestedMin.toCurrencyWith(currency),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              '—',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _result!.suggestedMax.toCurrencyWith(currency),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Chip(
                          label: Text(
                            'Confidence: ${_result!.confidenceLevel.toUpperCase()}',
                          ),
                          backgroundColor: _result!.confidenceLevel == 'high'
                              ? AppColors.success.withValues(alpha: 0.1)
                              : _result!.confidenceLevel == 'medium'
                              ? AppColors.warning.withValues(alpha: 0.1)
                              : AppColors.error.withValues(alpha: 0.1),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.recommendation,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _result!.reasoning,
                        style: theme.textTheme.bodyMedium,
                      ),
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

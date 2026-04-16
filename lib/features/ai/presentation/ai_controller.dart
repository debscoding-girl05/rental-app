import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:landlord_os/features/ai/data/groq_service.dart';
import 'package:landlord_os/features/ai/domain/price_prediction.dart';
import 'package:landlord_os/features/ai/domain/profitability_report.dart';
import 'package:landlord_os/features/properties/presentation/property_controller.dart';

part 'ai_controller.g.dart';

/// Manages AI feature state.
@riverpod
class AiController extends _$AiController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Sends a message to the AI assistant and returns the response.
  Future<String> askAssistant(String question) async {
    final service = ref.read(groqServiceProvider);
    final properties = ref.read(propertyControllerProvider).valueOrNull ?? [];
    return service.askAssistant(question: question, portfolio: properties);
  }

  /// Gets a rent price prediction.
  Future<PricePrediction> predictPrice({
    required String city,
    required String country,
    int? bedrooms,
    int? bathrooms,
    double? sizeSqm,
    String? notes,
    String? currencySymbol,
    String? currencyCode,
  }) async {
    return ref
        .read(groqServiceProvider)
        .predictRentPrice(
          city: city,
          country: country,
          bedrooms: bedrooms,
          bathrooms: bathrooms,
          sizeSqm: sizeSqm,
          notes: notes,
          currencySymbol: currencySymbol,
          currencyCode: currencyCode,
        );
  }

  /// Gets a profitability analysis.
  Future<ProfitabilityReport> analyzeProfitability({
    required double purchasePrice,
    required double mortgageMonthly,
    required double monthlyRent,
    required double monthlyExpenses,
    String? currencySymbol,
    String? currencyCode,
  }) async {
    return ref
        .read(groqServiceProvider)
        .analyzeProfitability(
          purchasePrice: purchasePrice,
          mortgageMonthly: mortgageMonthly,
          monthlyRent: monthlyRent,
          monthlyExpenses: monthlyExpenses,
          currencySymbol: currencySymbol,
          currencyCode: currencyCode,
        );
  }
}

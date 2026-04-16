import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/features/ai/domain/price_prediction.dart';
import 'package:landlord_os/features/ai/domain/profitability_report.dart';
import 'package:landlord_os/features/properties/domain/property_model.dart'
    show Property, PropertyTypes;

part 'groq_service.g.dart';

/// Handles all AI calls via a Supabase Edge Function (groq-proxy).
class GroqService {
  GroqService(this._client);

  final SupabaseClient _client;

  Future<String> _invoke({
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _client.functions.invoke(
      'groq-proxy',
      body: {'action': action, 'payload': payload},
    );
    final data = response.data as Map<String, dynamic>;
    if (data.containsKey('error')) {
      throw Exception(data['error']);
    }
    return data['content'] as String;
  }

  /// Extracts a JSON object from a response that may contain markdown fences.
  Map<String, dynamic> _parseJson(String raw) {
    var cleaned = raw.trim();
    // Strip markdown code fences
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceFirst(RegExp(r'^```\w*\n?'), '');
      cleaned = cleaned.replaceFirst(RegExp(r'\n?```$'), '');
    }
    return jsonDecode(cleaned.trim()) as Map<String, dynamic>;
  }

  /// Predicts a rent price range for a property.
  Future<PricePrediction> predictRentPrice({
    required String city,
    required String country,
    int? bedrooms,
    int? bathrooms,
    double? sizeSqm,
    String? notes,
  }) async {
    final userMessage = StringBuffer()
      ..writeln('Estimate monthly rent for:')
      ..writeln('City: $city, Country: $country')
      ..writeln(
        'Bedrooms: ${bedrooms ?? "N/A"}, Bathrooms: ${bathrooms ?? "N/A"}',
      )
      ..writeln('Size: ${sizeSqm != null ? "${sizeSqm}sqm" : "N/A"}');
    if (notes != null && notes.isNotEmpty) {
      userMessage.writeln('Additional info: $notes');
    }

    final raw = await _invoke(
      action: 'predict_rent',
      payload: {'message': userMessage.toString()},
    );
    final json = _parseJson(raw);
    return PricePrediction(
      suggestedMin: (json['suggested_min'] as num).toDouble(),
      suggestedMax: (json['suggested_max'] as num).toDouble(),
      reasoning: json['reasoning'] as String,
      confidenceLevel: json['confidence_level'] as String,
    );
  }

  /// Analyzes the profitability of a property.
  Future<ProfitabilityReport> analyzeProfitability({
    required double purchasePrice,
    required double mortgageMonthly,
    required double monthlyRent,
    required double monthlyExpenses,
  }) async {
    final userMessage =
        '''Analyze this rental property investment:
- Purchase price: \$${purchasePrice.toStringAsFixed(2)}
- Monthly mortgage: \$${mortgageMonthly.toStringAsFixed(2)}
- Monthly rent income: \$${monthlyRent.toStringAsFixed(2)}
- Monthly expenses (maintenance, insurance, tax): \$${monthlyExpenses.toStringAsFixed(2)}''';

    final raw = await _invoke(
      action: 'analyze_profitability',
      payload: {'message': userMessage},
    );
    final json = _parseJson(raw);
    return ProfitabilityReport(
      grossYield: (json['gross_yield'] as num).toDouble(),
      netYield: (json['net_yield'] as num).toDouble(),
      monthlyCashFlow: (json['monthly_cash_flow'] as num).toDouble(),
      annualRoi: (json['annual_roi'] as num).toDouble(),
      breakEvenTimeline: json['break_even_timeline'] as String,
      verdict: json['verdict'] as String,
    );
  }

  /// General-purpose AI assistant for landlord questions.
  Future<String> askAssistant({
    required String question,
    required List<Property> portfolio,
  }) async {
    final systemPrompt =
        '''You are LandlordOS AI, a helpful assistant for landlords.
You have access to the user's portfolio summary below. Answer their questions
about property management, tenant relations, legal considerations, and finances.
Be concise and practical.

Portfolio summary:
${portfolio.map((p) => '- ${p.name}: ${p.city}, ${p.country} (${PropertyTypes.label(p.propertyType)}, ${p.totalUnits} units, ${p.floors} floors)').join('\n')}
Total properties: ${portfolio.length}''';

    return _invoke(
      action: 'ask_assistant',
      payload: {'systemPrompt': systemPrompt, 'message': question},
    );
  }
}

@riverpod
GroqService groqService(Ref ref) {
  return GroqService(Supabase.instance.client);
}

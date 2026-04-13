import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:landlord_os/features/ai/domain/price_prediction.dart';
import 'package:landlord_os/features/ai/domain/profitability_report.dart';
import 'package:landlord_os/features/properties/domain/property_model.dart' show Property, PropertyTypes;

part 'groq_service.g.dart';

/// Handles all AI calls via the Groq API (OpenAI-compatible).
class GroqService {
  GroqService(this._dio);

  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  final Dio _dio;

  String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  Future<String> _sendMessage({
    required String systemPrompt,
    required String userMessage,
  }) async {
    final response = await _dio.post(
      _baseUrl,
      options: Options(headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      }),
      data: {
        'model': _model,
        'max_tokens': 1024,
        'temperature': 0.3,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userMessage},
        ],
      },
    );
    return response.data['choices'][0]['message']['content'] as String;
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
    const systemPrompt = '''You are a real estate rental pricing expert.
Respond ONLY with a JSON object (no markdown fences, no extra text) with these keys:
- "suggested_min": number (monthly rent, lower bound)
- "suggested_max": number (monthly rent, upper bound)
- "reasoning": string (2-3 sentences explaining the estimate)
- "confidence_level": string ("low", "medium", or "high")''';

    final userMessage = StringBuffer()
      ..writeln('Estimate monthly rent for:')
      ..writeln('City: $city, Country: $country')
      ..writeln('Bedrooms: ${bedrooms ?? "N/A"}, Bathrooms: ${bathrooms ?? "N/A"}')
      ..writeln('Size: ${sizeSqm != null ? "${sizeSqm}sqm" : "N/A"}');
    if (notes != null && notes.isNotEmpty) {
      userMessage.writeln('Additional info: $notes');
    }

    final raw = await _sendMessage(
      systemPrompt: systemPrompt,
      userMessage: userMessage.toString(),
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
    const systemPrompt = '''You are a real estate investment analyst.
Respond ONLY with a JSON object (no markdown fences, no extra text) with these keys:
- "gross_yield": number (percentage)
- "net_yield": number (percentage)
- "monthly_cash_flow": number
- "annual_roi": number (percentage)
- "break_even_timeline": string (e.g. "15 years")
- "verdict": string (2-3 sentence assessment)''';

    final userMessage = '''Analyze this rental property investment:
- Purchase price: \$${purchasePrice.toStringAsFixed(2)}
- Monthly mortgage: \$${mortgageMonthly.toStringAsFixed(2)}
- Monthly rent income: \$${monthlyRent.toStringAsFixed(2)}
- Monthly expenses (maintenance, insurance, tax): \$${monthlyExpenses.toStringAsFixed(2)}''';

    final raw = await _sendMessage(
      systemPrompt: systemPrompt,
      userMessage: userMessage,
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
    final systemPrompt = '''You are LandlordOS AI, a helpful assistant for landlords.
You have access to the user's portfolio summary below. Answer their questions
about property management, tenant relations, legal considerations, and finances.
Be concise and practical.

Portfolio summary:
${portfolio.map((p) => '- ${p.name}: ${p.city}, ${p.country} (${PropertyTypes.label(p.propertyType)}, ${p.totalUnits} units, ${p.floors} floors)').join('\n')}
Total properties: ${portfolio.length}''';

    return _sendMessage(systemPrompt: systemPrompt, userMessage: question);
  }
}

@riverpod
GroqService groqService(Ref ref) {
  return GroqService(Dio());
}

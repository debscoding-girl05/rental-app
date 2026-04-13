import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_prediction.freezed.dart';
part 'price_prediction.g.dart';

/// Result of an AI-powered rent price prediction.
@freezed
class PricePrediction with _$PricePrediction {
  const factory PricePrediction({
    required double suggestedMin,
    required double suggestedMax,
    required String reasoning,
    required String confidenceLevel,
  }) = _PricePrediction;

  factory PricePrediction.fromJson(Map<String, dynamic> json) =>
      _$PricePredictionFromJson(json);
}

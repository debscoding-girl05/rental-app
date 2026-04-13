import 'package:freezed_annotation/freezed_annotation.dart';

part 'profitability_report.freezed.dart';
part 'profitability_report.g.dart';

/// Result of an AI-powered profitability analysis.
@freezed
class ProfitabilityReport with _$ProfitabilityReport {
  const factory ProfitabilityReport({
    required double grossYield,
    required double netYield,
    required double monthlyCashFlow,
    required double annualRoi,
    required String breakEvenTimeline,
    required String verdict,
  }) = _ProfitabilityReport;

  factory ProfitabilityReport.fromJson(Map<String, dynamic> json) =>
      _$ProfitabilityReportFromJson(json);
}

import 'package:intl/intl.dart';

/// Currency and number formatting helpers.
extension NumExt on num {
  /// Formats as currency, e.g. "$1,234.56".
  String toCurrency({String symbol = '\$', int decimalDigits = 2}) {
    return NumberFormat.currency(symbol: symbol, decimalDigits: decimalDigits)
        .format(this);
  }

  /// Formats with commas, e.g. "1,234".
  String get formatted => NumberFormat('#,##0').format(this);

  /// Formats as a percentage, e.g. "12.5%".
  String toPercentage({int decimalDigits = 1}) {
    return '${toStringAsFixed(decimalDigits)}%';
  }
}

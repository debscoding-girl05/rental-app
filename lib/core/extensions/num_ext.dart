import 'package:intl/intl.dart';

import 'package:landlord_os/core/constants/currencies.dart';

/// Currency and number formatting helpers.
extension NumExt on num {
  /// Formats using a [Currency] object (preferred).
  String toCurrencyWith(Currency currency) {
    return NumberFormat.currency(
      symbol: '${currency.symbol} ',
      decimalDigits: currency.decimalDigits,
    ).format(this);
  }

  /// Formats as currency with explicit symbol (legacy).
  String toCurrency({String symbol = '\$', int decimalDigits = 2}) {
    return NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    ).format(this);
  }

  /// Formats with commas, e.g. "1,234".
  String get formatted => NumberFormat('#,##0').format(this);

  /// Formats as a percentage, e.g. "12.5%".
  String toPercentage({int decimalDigits = 1}) {
    return '${toStringAsFixed(decimalDigits)}%';
  }
}

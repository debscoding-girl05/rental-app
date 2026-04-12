import 'package:intl/intl.dart';

/// Formatting helpers for [DateTime].
extension DateTimeExt on DateTime {
  /// e.g. "12 Apr 2026"
  String get formatted => DateFormat('dd MMM yyyy').format(this);

  /// e.g. "Apr 2026"
  String get monthYear => DateFormat('MMM yyyy').format(this);

  /// e.g. "12/04/2026"
  String get shortDate => DateFormat('dd/MM/yyyy').format(this);

  /// e.g. "12 Apr 2026, 14:30"
  String get formattedWithTime => DateFormat('dd MMM yyyy, HH:mm').format(this);
}

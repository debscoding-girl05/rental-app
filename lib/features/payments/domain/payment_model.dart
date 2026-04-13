import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

/// A payment record (rent, deposit, or other).
@freezed
class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String landlordId,
    required String tenantId,
    required String propertyId,
    String? unitId,
    @Default('rent') String type, // 'rent', 'deposit', 'other'
    required double amount,
    @Default('XOF') String currency,
    required DateTime date,
    DateTime? dueDate,
    String? periodLabel, // e.g. "Avril 2026", "Deposit 3/6"
    @Default('cash') String paymentMethod,
    String? notes,
    String? receiptUrl,
    DateTime? createdAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}

/// Allowed payment types.
abstract final class PaymentTypes {
  static const all = ['rent', 'deposit', 'other'];

  static String label(String type) => switch (type) {
    'rent' => 'Loyer',
    'deposit' => 'Caution',
    'other' => 'Autre',
    _ => type,
  };
}

/// Allowed payment methods.
abstract final class PaymentMethods {
  static const all = [
    'cash',
    'mobile_money',
    'bank_transfer',
    'cheque',
    'other',
  ];

  static String label(String method) => switch (method) {
    'cash' => 'Especes',
    'mobile_money' => 'Mobile Money',
    'bank_transfer' => 'Virement',
    'cheque' => 'Cheque',
    'other' => 'Autre',
    _ => method,
  };
}

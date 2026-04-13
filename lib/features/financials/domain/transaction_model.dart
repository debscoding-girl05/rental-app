import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

/// A financial transaction (income or expense) for a property.
@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String landlordId,
    required String propertyId,
    String? tenantId,
    required String type, // 'income' or 'expense'
    required String category, // 'rent', 'maintenance', 'insurance', 'tax', etc.
    required double amount,
    required DateTime date,
    String? description,
    String? receiptUrl,
    DateTime? createdAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}

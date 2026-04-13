import 'package:landlord_os/features/financials/domain/transaction_model.dart';

/// Maps between Supabase row format and [Transaction] domain model.
class TransactionDto {
  const TransactionDto._();

  /// Converts a Supabase row (snake_case) to a [Transaction].
  static Transaction fromRow(Map<String, dynamic> row) {
    return Transaction(
      id: row['id'] as String,
      landlordId: row['landlord_id'] as String,
      propertyId: row['property_id'] as String,
      tenantId: row['tenant_id'] as String?,
      type: row['type'] as String,
      category: row['category'] as String,
      amount: (row['amount'] as num).toDouble(),
      date: DateTime.parse(row['date'] as String),
      description: row['description'] as String?,
      receiptUrl: row['receipt_url'] as String?,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : null,
    );
  }

  /// Converts a [Transaction] to a Supabase row (snake_case).
  static Map<String, dynamic> toRow(Transaction tx) {
    return {
      'landlord_id': tx.landlordId,
      'property_id': tx.propertyId,
      'tenant_id': tx.tenantId,
      'type': tx.type,
      'category': tx.category,
      'amount': tx.amount,
      'date': tx.date.toIso8601String().split('T').first,
      'description': tx.description,
      'receipt_url': tx.receiptUrl,
    };
  }
}

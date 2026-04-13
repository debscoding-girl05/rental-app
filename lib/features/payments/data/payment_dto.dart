import 'package:landlord_os/features/payments/domain/payment_model.dart';

/// Maps between Supabase row format and [Payment] domain model.
class PaymentDto {
  const PaymentDto._();

  static Payment fromRow(Map<String, dynamic> row) {
    return Payment(
      id: row['id'] as String,
      landlordId: row['landlord_id'] as String,
      tenantId: row['tenant_id'] as String,
      propertyId: row['property_id'] as String,
      unitId: row['unit_id'] as String?,
      type: row['type'] as String? ?? 'rent',
      amount: (row['amount'] as num).toDouble(),
      currency: row['currency'] as String? ?? 'XOF',
      date: DateTime.parse(row['date'] as String),
      dueDate: row['due_date'] != null
          ? DateTime.parse(row['due_date'] as String)
          : null,
      periodLabel: row['period_label'] as String?,
      paymentMethod: row['payment_method'] as String? ?? 'cash',
      notes: row['notes'] as String?,
      receiptUrl: row['receipt_url'] as String?,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : null,
    );
  }

  static Map<String, dynamic> toRow(Payment payment) {
    return {
      'landlord_id': payment.landlordId,
      'tenant_id': payment.tenantId,
      'property_id': payment.propertyId,
      'unit_id': payment.unitId,
      'type': payment.type,
      'amount': payment.amount,
      'currency': payment.currency,
      'date': payment.date.toIso8601String().split('T').first,
      'due_date': payment.dueDate?.toIso8601String().split('T').first,
      'period_label': payment.periodLabel,
      'payment_method': payment.paymentMethod,
      'notes': payment.notes,
      'receipt_url': payment.receiptUrl,
    };
  }
}

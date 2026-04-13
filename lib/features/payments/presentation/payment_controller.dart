import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:landlord_os/features/payments/data/payment_repository.dart';
import 'package:landlord_os/features/payments/domain/payment_model.dart';

part 'payment_controller.g.dart';

/// Manages payment operations.
@riverpod
class PaymentController extends _$PaymentController {
  @override
  Future<List<Payment>> build() async {
    return ref.watch(paymentRepositoryProvider).getAll();
  }

  /// Adds a new payment and refreshes the list.
  Future<void> addPayment(Payment payment) async {
    await ref.read(paymentRepositoryProvider).add(payment);
    ref.invalidateSelf();
  }

  /// Deletes a payment and refreshes the list.
  Future<void> deletePayment(String id) async {
    await ref.read(paymentRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

/// Fetches payments for a specific tenant.
@riverpod
Future<List<Payment>> tenantPayments(Ref ref, String tenantId) async {
  return ref.watch(paymentRepositoryProvider).getByTenant(tenantId);
}

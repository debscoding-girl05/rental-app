import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:landlord_os/features/financials/data/transaction_repository.dart';
import 'package:landlord_os/features/financials/domain/transaction_model.dart';

part 'financials_controller.g.dart';

/// Manages the list of transactions and CRUD operations.
@riverpod
class FinancialsController extends _$FinancialsController {
  @override
  Future<List<Transaction>> build() async {
    return ref.watch(transactionRepositoryProvider).getAll();
  }

  /// Adds a new transaction and refreshes the list.
  Future<void> addTransaction(Transaction tx) async {
    await ref.read(transactionRepositoryProvider).add(tx);
    ref.invalidateSelf();
  }

  /// Deletes a transaction and refreshes the list.
  Future<void> deleteTransaction(String id) async {
    await ref.read(transactionRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

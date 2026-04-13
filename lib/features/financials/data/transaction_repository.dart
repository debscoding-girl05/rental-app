import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/errors/app_exception.dart';
import 'package:landlord_os/features/financials/data/transaction_dto.dart';
import 'package:landlord_os/features/financials/domain/financial_summary.dart';
import 'package:landlord_os/features/financials/domain/transaction_model.dart';

part 'transaction_repository.g.dart';

/// Handles all Supabase CRUD operations for transactions.
class TransactionRepository {
  TransactionRepository(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  /// Fetches all transactions for the current landlord.
  Future<List<Transaction>> getAll() async {
    try {
      final rows = await _client
          .from('transactions')
          .select()
          .eq('landlord_id', _userId)
          .order('date', ascending: false);
      return rows.map(TransactionDto.fromRow).toList();
    } catch (e) {
      throw ServerException('Failed to load transactions: $e');
    }
  }

  /// Inserts a new transaction.
  Future<Transaction> add(Transaction tx) async {
    try {
      final row = await _client
          .from('transactions')
          .insert(TransactionDto.toRow(tx))
          .select()
          .single();
      return TransactionDto.fromRow(row);
    } catch (e) {
      throw ServerException('Failed to add transaction: $e');
    }
  }

  /// Deletes a transaction by ID.
  Future<void> delete(String id) async {
    try {
      await _client.from('transactions').delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete transaction: $e');
    }
  }

  /// Computes a financial summary from a list of transactions.
  FinancialSummary computeSummary(List<Transaction> transactions) {
    double totalIncome = 0;
    double totalExpenses = 0;
    final incomeByCategory = <String, double>{};
    final expensesByCategory = <String, double>{};

    for (final tx in transactions) {
      if (tx.type == 'income') {
        totalIncome += tx.amount;
        incomeByCategory[tx.category] =
            (incomeByCategory[tx.category] ?? 0) + tx.amount;
      } else {
        totalExpenses += tx.amount;
        expensesByCategory[tx.category] =
            (expensesByCategory[tx.category] ?? 0) + tx.amount;
      }
    }

    return FinancialSummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      incomeByCategory: incomeByCategory,
      expensesByCategory: expensesByCategory,
    );
  }
}

@riverpod
TransactionRepository transactionRepository(Ref ref) {
  return TransactionRepository(Supabase.instance.client);
}

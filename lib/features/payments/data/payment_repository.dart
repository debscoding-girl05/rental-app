import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/errors/app_exception.dart';
import 'package:landlord_os/features/payments/data/payment_dto.dart';
import 'package:landlord_os/features/payments/domain/payment_model.dart';

part 'payment_repository.g.dart';

/// Handles all Supabase CRUD operations for payments.
class PaymentRepository {
  PaymentRepository(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  /// Fetches all payments for the current landlord.
  Future<List<Payment>> getAll() async {
    try {
      final rows = await _client
          .from('payments')
          .select()
          .eq('landlord_id', _userId)
          .order('date', ascending: false);
      return rows.map(PaymentDto.fromRow).toList();
    } catch (e) {
      throw ServerException('Failed to load payments: $e');
    }
  }

  /// Fetches payments for a specific tenant.
  Future<List<Payment>> getByTenant(String tenantId) async {
    try {
      final rows = await _client
          .from('payments')
          .select()
          .eq('landlord_id', _userId)
          .eq('tenant_id', tenantId)
          .order('date', ascending: false);
      return rows.map(PaymentDto.fromRow).toList();
    } catch (e) {
      throw ServerException('Failed to load payments: $e');
    }
  }

  /// Fetches payments for a specific property.
  Future<List<Payment>> getByProperty(String propertyId) async {
    try {
      final rows = await _client
          .from('payments')
          .select()
          .eq('landlord_id', _userId)
          .eq('property_id', propertyId)
          .order('date', ascending: false);
      return rows.map(PaymentDto.fromRow).toList();
    } catch (e) {
      throw ServerException('Failed to load payments: $e');
    }
  }

  /// Inserts a new payment.
  Future<Payment> add(Payment payment) async {
    try {
      final row = await _client
          .from('payments')
          .insert(PaymentDto.toRow(payment))
          .select()
          .single();
      return PaymentDto.fromRow(row);
    } catch (e) {
      throw ServerException('Failed to add payment: $e');
    }
  }

  /// Deletes a payment by ID.
  Future<void> delete(String id) async {
    try {
      await _client.from('payments').delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete payment: $e');
    }
  }
}

@riverpod
PaymentRepository paymentRepository(Ref ref) {
  return PaymentRepository(Supabase.instance.client);
}

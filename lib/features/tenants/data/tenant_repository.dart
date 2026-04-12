import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/errors/app_exception.dart';
import 'package:landlord_os/features/tenants/data/tenant_dto.dart';
import 'package:landlord_os/features/tenants/domain/tenant_model.dart';

part 'tenant_repository.g.dart';

/// Handles all Supabase CRUD operations for tenants.
class TenantRepository {
  TenantRepository(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  /// Fetches all tenants for the current landlord.
  Future<List<Tenant>> getAll() async {
    try {
      final rows = await _client
          .from('tenants')
          .select()
          .eq('landlord_id', _userId)
          .order('created_at', ascending: false);
      return rows.map(TenantDto.fromRow).toList();
    } catch (e) {
      throw ServerException('Failed to load tenants: $e');
    }
  }

  /// Fetches tenants for a specific property.
  Future<List<Tenant>> getByProperty(String propertyId) async {
    try {
      final rows = await _client
          .from('tenants')
          .select()
          .eq('landlord_id', _userId)
          .eq('property_id', propertyId)
          .order('created_at', ascending: false);
      return rows.map(TenantDto.fromRow).toList();
    } catch (e) {
      throw ServerException('Failed to load tenants: $e');
    }
  }

  /// Fetches a single tenant by ID.
  Future<Tenant> getById(String id) async {
    try {
      final row =
          await _client.from('tenants').select().eq('id', id).single();
      return TenantDto.fromRow(row);
    } catch (e) {
      throw NotFoundException('Tenant not found.');
    }
  }

  /// Inserts a new tenant and returns it with the generated ID.
  Future<Tenant> add(Tenant tenant) async {
    try {
      final row = await _client
          .from('tenants')
          .insert(TenantDto.toRow(tenant))
          .select()
          .single();
      return TenantDto.fromRow(row);
    } catch (e) {
      throw ServerException('Failed to add tenant: $e');
    }
  }

  /// Updates an existing tenant.
  Future<Tenant> update(Tenant tenant) async {
    try {
      final row = await _client
          .from('tenants')
          .update(TenantDto.toRow(tenant))
          .eq('id', tenant.id)
          .select()
          .single();
      return TenantDto.fromRow(row);
    } catch (e) {
      throw ServerException('Failed to update tenant: $e');
    }
  }

  /// Deletes a tenant by ID.
  Future<void> delete(String id) async {
    try {
      await _client.from('tenants').delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete tenant: $e');
    }
  }
}

@riverpod
TenantRepository tenantRepository(Ref ref) {
  return TenantRepository(Supabase.instance.client);
}

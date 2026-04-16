import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/errors/app_exception.dart';
import 'package:landlord_os/features/maintenance/data/maintenance_dto.dart';
import 'package:landlord_os/features/maintenance/domain/maintenance_request_model.dart';

part 'maintenance_repository.g.dart';

/// Handles all Supabase CRUD for maintenance requests.
class MaintenanceRepository {
  MaintenanceRepository(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  /// Fetches all maintenance requests for the current landlord.
  Future<List<MaintenanceRequest>> getAll() async {
    try {
      final rows = await _client
          .from('maintenance_requests')
          .select()
          .eq('landlord_id', _userId)
          .order('created_at', ascending: false);
      return rows.map(MaintenanceDto.fromRow).toList();
    } catch (e) {
      throw ServerException('Failed to load maintenance requests: $e');
    }
  }

  /// Fetches maintenance requests for a specific property.
  Future<List<MaintenanceRequest>> getByProperty(String propertyId) async {
    try {
      final rows = await _client
          .from('maintenance_requests')
          .select()
          .eq('landlord_id', _userId)
          .eq('property_id', propertyId)
          .order('created_at', ascending: false);
      return rows.map(MaintenanceDto.fromRow).toList();
    } catch (e) {
      throw ServerException('Failed to load maintenance requests: $e');
    }
  }

  /// Inserts a new maintenance request.
  Future<MaintenanceRequest> add(MaintenanceRequest req) async {
    try {
      final row = await _client
          .from('maintenance_requests')
          .insert(MaintenanceDto.toRow(req))
          .select()
          .single();
      return MaintenanceDto.fromRow(row);
    } catch (e) {
      throw ServerException('Failed to add maintenance request: $e');
    }
  }

  /// Updates the status of a maintenance request.
  Future<MaintenanceRequest> updateStatus(
    String id, {
    required String status,
    double? cost,
  }) async {
    try {
      final data = <String, dynamic>{'status': status};
      if (status == 'resolved') {
        data['resolved_at'] = DateTime.now().toIso8601String();
      }
      if (cost != null) {
        data['cost'] = cost;
      }
      final row = await _client
          .from('maintenance_requests')
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return MaintenanceDto.fromRow(row);
    } catch (e) {
      throw ServerException('Failed to update maintenance request: $e');
    }
  }

  /// Deletes a maintenance request.
  Future<void> delete(String id) async {
    try {
      await _client.from('maintenance_requests').delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete maintenance request: $e');
    }
  }
}

@riverpod
MaintenanceRepository maintenanceRepository(Ref ref) {
  return MaintenanceRepository(Supabase.instance.client);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/errors/app_exception.dart';
import 'package:landlord_os/features/properties/data/unit_dto.dart';
import 'package:landlord_os/features/properties/domain/unit_model.dart';

part 'unit_repository.g.dart';

/// Handles all Supabase CRUD operations for units.
class UnitRepository {
  UnitRepository(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  /// Fetches all units for a given property.
  Future<List<Unit>> getByProperty(String propertyId) async {
    try {
      final rows = await _client
          .from('units')
          .select()
          .eq('landlord_id', _userId)
          .eq('property_id', propertyId)
          .order('floor_number')
          .order('unit_label');
      return rows.map(UnitDto.fromRow).toList();
    } catch (e) {
      throw ServerException('Failed to load units: $e');
    }
  }

  /// Fetches all units for the current landlord.
  Future<List<Unit>> getAll() async {
    try {
      final rows = await _client
          .from('units')
          .select()
          .eq('landlord_id', _userId)
          .order('created_at', ascending: false);
      return rows.map(UnitDto.fromRow).toList();
    } catch (e) {
      throw ServerException('Failed to load units: $e');
    }
  }

  /// Inserts a new unit.
  Future<Unit> add(Unit unit) async {
    try {
      final row = await _client
          .from('units')
          .insert(UnitDto.toRow(unit))
          .select()
          .single();
      return UnitDto.fromRow(row);
    } catch (e) {
      throw ServerException('Failed to add unit: $e');
    }
  }

  /// Updates an existing unit.
  Future<Unit> update(Unit unit) async {
    try {
      final row = await _client
          .from('units')
          .update(UnitDto.toRow(unit))
          .eq('id', unit.id)
          .select()
          .single();
      return UnitDto.fromRow(row);
    } catch (e) {
      throw ServerException('Failed to update unit: $e');
    }
  }

  /// Deletes a unit by ID.
  Future<void> delete(String id) async {
    try {
      await _client.from('units').delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete unit: $e');
    }
  }
}

@riverpod
UnitRepository unitRepository(Ref ref) {
  return UnitRepository(Supabase.instance.client);
}

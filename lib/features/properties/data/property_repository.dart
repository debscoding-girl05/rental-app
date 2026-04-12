import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/errors/app_exception.dart';
import 'package:landlord_os/features/properties/data/property_dto.dart';
import 'package:landlord_os/features/properties/domain/property_model.dart';

part 'property_repository.g.dart';

/// Handles all Supabase CRUD operations for properties.
class PropertyRepository {
  PropertyRepository(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  /// Fetches all properties for the current landlord.
  Future<List<Property>> getAll() async {
    try {
      final rows = await _client
          .from('properties')
          .select()
          .eq('landlord_id', _userId)
          .order('created_at', ascending: false);
      return rows.map(PropertyDto.fromRow).toList();
    } catch (e) {
      throw ServerException('Failed to load properties: $e');
    }
  }

  /// Fetches a single property by ID.
  Future<Property> getById(String id) async {
    try {
      final row =
          await _client.from('properties').select().eq('id', id).single();
      return PropertyDto.fromRow(row);
    } catch (e) {
      throw NotFoundException('Property not found.');
    }
  }

  /// Inserts a new property and returns it with the generated ID.
  Future<Property> add(Property property) async {
    try {
      final row = await _client
          .from('properties')
          .insert(PropertyDto.toRow(property))
          .select()
          .single();
      return PropertyDto.fromRow(row);
    } catch (e) {
      throw ServerException('Failed to add property: $e');
    }
  }

  /// Updates an existing property.
  Future<Property> update(Property property) async {
    try {
      final row = await _client
          .from('properties')
          .update(PropertyDto.toRow(property))
          .eq('id', property.id)
          .select()
          .single();
      return PropertyDto.fromRow(row);
    } catch (e) {
      throw ServerException('Failed to update property: $e');
    }
  }

  /// Deletes a property by ID.
  Future<void> delete(String id) async {
    try {
      await _client.from('properties').delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete property: $e');
    }
  }
}

@riverpod
PropertyRepository propertyRepository(Ref ref) {
  return PropertyRepository(Supabase.instance.client);
}

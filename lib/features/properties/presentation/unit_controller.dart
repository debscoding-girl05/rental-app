import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:landlord_os/features/properties/data/unit_repository.dart';
import 'package:landlord_os/features/properties/domain/unit_model.dart';

part 'unit_controller.g.dart';

/// Manages units for a specific property.
@riverpod
class UnitController extends _$UnitController {
  @override
  Future<List<Unit>> build(String propertyId) async {
    return ref.watch(unitRepositoryProvider).getByProperty(propertyId);
  }

  /// Adds a new unit and refreshes the list.
  Future<void> addUnit(Unit unit) async {
    await ref.read(unitRepositoryProvider).add(unit);
    ref.invalidateSelf();
  }

  /// Updates an existing unit and refreshes the list.
  Future<void> updateUnit(Unit unit) async {
    await ref.read(unitRepositoryProvider).update(unit);
    ref.invalidateSelf();
  }

  /// Deletes a unit and refreshes the list.
  Future<void> deleteUnit(String id) async {
    await ref.read(unitRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:landlord_os/features/properties/data/property_repository.dart';
import 'package:landlord_os/features/properties/domain/property_model.dart';

part 'property_controller.g.dart';

/// Manages the list of properties and CRUD operations.
@riverpod
class PropertyController extends _$PropertyController {
  @override
  Future<List<Property>> build() async {
    return ref.watch(propertyRepositoryProvider).getAll();
  }

  /// Adds a new property and refreshes the list.
  Future<void> addProperty(Property property) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(propertyRepositoryProvider).getAll(),
    );
    await ref.read(propertyRepositoryProvider).add(property);
    ref.invalidateSelf();
  }

  /// Updates an existing property and refreshes the list.
  Future<void> updateProperty(Property property) async {
    await ref.read(propertyRepositoryProvider).update(property);
    ref.invalidateSelf();
  }

  /// Deletes a property and refreshes the list.
  Future<void> deleteProperty(String id) async {
    await ref.read(propertyRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

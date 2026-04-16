import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:landlord_os/features/maintenance/data/maintenance_repository.dart';
import 'package:landlord_os/features/maintenance/domain/maintenance_request_model.dart';

part 'maintenance_controller.g.dart';

/// Manages maintenance requests state.
@riverpod
class MaintenanceController extends _$MaintenanceController {
  @override
  Future<List<MaintenanceRequest>> build() async {
    return ref.watch(maintenanceRepositoryProvider).getAll();
  }

  /// Adds a new maintenance request.
  Future<void> addRequest(MaintenanceRequest req) async {
    await ref.read(maintenanceRepositoryProvider).add(req);
    ref.invalidateSelf();
  }

  /// Updates the status of a request (e.g. open → in_progress → resolved).
  Future<void> updateStatus(
    String id, {
    required String status,
    double? cost,
  }) async {
    await ref.read(maintenanceRepositoryProvider).updateStatus(
          id,
          status: status,
          cost: cost,
        );
    ref.invalidateSelf();
  }

  /// Deletes a maintenance request.
  Future<void> deleteRequest(String id) async {
    await ref.read(maintenanceRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

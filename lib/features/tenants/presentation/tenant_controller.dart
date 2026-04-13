import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:landlord_os/core/services/notification_service.dart';
import 'package:landlord_os/features/tenants/data/tenant_repository.dart';
import 'package:landlord_os/features/tenants/domain/tenant_model.dart';

part 'tenant_controller.g.dart';

/// Manages the list of tenants and CRUD operations.
@riverpod
class TenantController extends _$TenantController {
  @override
  Future<List<Tenant>> build() async {
    return ref.watch(tenantRepositoryProvider).getAll();
  }

  /// Adds a new tenant and refreshes the list.
  Future<void> addTenant(Tenant tenant) async {
    await ref.read(tenantRepositoryProvider).add(tenant);
    ref.invalidateSelf();
    await NotificationService.instance.scheduleRentReminder(tenant);
  }

  /// Updates an existing tenant and refreshes the list.
  Future<void> updateTenant(Tenant tenant) async {
    await ref.read(tenantRepositoryProvider).update(tenant);
    ref.invalidateSelf();
    await NotificationService.instance.scheduleRentReminder(tenant);
  }

  /// Deletes a tenant and refreshes the list.
  Future<void> deleteTenant(String id) async {
    await ref.read(tenantRepositoryProvider).delete(id);
    ref.invalidateSelf();
    await NotificationService.instance.cancelTenantReminders(id);
  }
}

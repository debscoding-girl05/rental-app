import 'package:freezed_annotation/freezed_annotation.dart';

part 'maintenance_request_model.freezed.dart';
part 'maintenance_request_model.g.dart';

/// A maintenance/repair request for a property or unit.
@freezed
class MaintenanceRequest with _$MaintenanceRequest {
  const factory MaintenanceRequest({
    required String id,
    required String landlordId,
    required String propertyId,
    String? unitId,
    String? tenantId,
    required String title,
    String? description,
    @Default('open') String status,
    @Default('medium') String priority,
    double? cost,
    @Default([]) List<String> photos,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) = _MaintenanceRequest;

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceRequestFromJson(json);
}

/// Maintenance request statuses.
abstract final class MaintenanceStatuses {
  static const all = ['open', 'in_progress', 'resolved'];

  static String label(String status) => switch (status) {
        'open' => 'Ouvert',
        'in_progress' => 'En cours',
        'resolved' => 'Résolu',
        _ => status,
      };
}

/// Maintenance request priorities.
abstract final class MaintenancePriorities {
  static const all = ['low', 'medium', 'high', 'urgent'];

  static String label(String priority) => switch (priority) {
        'low' => 'Basse',
        'medium' => 'Moyenne',
        'high' => 'Haute',
        'urgent' => 'Urgente',
        _ => priority,
      };
}

import 'package:landlord_os/features/maintenance/domain/maintenance_request_model.dart';

/// Maps between Supabase row format and [MaintenanceRequest].
class MaintenanceDto {
  const MaintenanceDto._();

  static MaintenanceRequest fromRow(Map<String, dynamic> row) {
    return MaintenanceRequest(
      id: row['id'] as String,
      landlordId: row['landlord_id'] as String,
      propertyId: row['property_id'] as String,
      unitId: row['unit_id'] as String?,
      tenantId: row['tenant_id'] as String?,
      title: row['title'] as String,
      description: row['description'] as String?,
      status: row['status'] as String? ?? 'open',
      priority: row['priority'] as String? ?? 'medium',
      cost: (row['cost'] as num?)?.toDouble(),
      photos: (row['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : null,
      resolvedAt: row['resolved_at'] != null
          ? DateTime.parse(row['resolved_at'] as String)
          : null,
    );
  }

  static Map<String, dynamic> toRow(MaintenanceRequest req) {
    return {
      'landlord_id': req.landlordId,
      'property_id': req.propertyId,
      'unit_id': req.unitId,
      'tenant_id': req.tenantId,
      'title': req.title,
      'description': req.description,
      'status': req.status,
      'priority': req.priority,
      'cost': req.cost,
      'photos': req.photos,
    };
  }
}

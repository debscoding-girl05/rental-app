import 'package:landlord_os/features/tenants/domain/tenant_model.dart';

/// Maps between Supabase row format and [Tenant] domain model.
class TenantDto {
  const TenantDto._();

  /// Converts a Supabase row (snake_case) to a [Tenant].
  static Tenant fromRow(Map<String, dynamic> row) {
    return Tenant(
      id: row['id'] as String,
      landlordId: row['landlord_id'] as String,
      propertyId: row['property_id'] as String?,
      fullName: row['full_name'] as String,
      email: row['email'] as String?,
      phone: row['phone'] as String?,
      leaseStart: row['lease_start'] != null
          ? DateTime.parse(row['lease_start'] as String)
          : null,
      leaseEnd: row['lease_end'] != null
          ? DateTime.parse(row['lease_end'] as String)
          : null,
      rentAmount: (row['rent_amount'] as num).toDouble(),
      depositAmount: (row['deposit_amount'] as num?)?.toDouble(),
      leaseDocumentUrl: row['lease_document_url'] as String?,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : null,
    );
  }

  /// Converts a [Tenant] to a Supabase row (snake_case).
  /// Omits `id` and `created_at` (set by the database).
  static Map<String, dynamic> toRow(Tenant tenant) {
    return {
      'landlord_id': tenant.landlordId,
      'property_id': tenant.propertyId,
      'full_name': tenant.fullName,
      'email': tenant.email,
      'phone': tenant.phone,
      'lease_start': tenant.leaseStart?.toIso8601String(),
      'lease_end': tenant.leaseEnd?.toIso8601String(),
      'rent_amount': tenant.rentAmount,
      'deposit_amount': tenant.depositAmount,
      'lease_document_url': tenant.leaseDocumentUrl,
    };
  }
}

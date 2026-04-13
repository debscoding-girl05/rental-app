import 'package:landlord_os/features/tenants/domain/tenant_model.dart';

/// Maps between Supabase row format and [Tenant] domain model.
class TenantDto {
  const TenantDto._();

  static Tenant fromRow(Map<String, dynamic> row) {
    return Tenant(
      id: row['id'] as String,
      landlordId: row['landlord_id'] as String,
      unitId: row['unit_id'] as String?,
      fullName: row['full_name'] as String,
      email: row['email'] as String?,
      phone: row['phone'] as String?,
      idNumber: row['id_number'] as String?,
      leaseStart: row['lease_start'] != null
          ? DateTime.parse(row['lease_start'] as String)
          : null,
      leaseEnd: row['lease_end'] != null
          ? DateTime.parse(row['lease_end'] as String)
          : null,
      rentAmount: (row['rent_amount'] as num).toDouble(),
      depositAmount: (row['deposit_amount'] as num?)?.toDouble(),
      paymentFrequency: row['payment_frequency'] as String? ?? 'monthly',
      photoUrl: row['photo_url'] as String?,
      idPhotoUrl: row['id_photo_url'] as String?,
      leaseDocumentUrl: row['lease_document_url'] as String?,
      notes: row['notes'] as String?,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : null,
    );
  }

  static Map<String, dynamic> toRow(Tenant tenant) {
    return {
      'landlord_id': tenant.landlordId,
      'unit_id': tenant.unitId,
      'full_name': tenant.fullName,
      'email': tenant.email,
      'phone': tenant.phone,
      'id_number': tenant.idNumber,
      'lease_start': tenant.leaseStart?.toIso8601String(),
      'lease_end': tenant.leaseEnd?.toIso8601String(),
      'rent_amount': tenant.rentAmount,
      'deposit_amount': tenant.depositAmount,
      'payment_frequency': tenant.paymentFrequency,
      'photo_url': tenant.photoUrl,
      'id_photo_url': tenant.idPhotoUrl,
      'lease_document_url': tenant.leaseDocumentUrl,
      'notes': tenant.notes,
    };
  }
}

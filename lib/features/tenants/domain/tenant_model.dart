import 'package:freezed_annotation/freezed_annotation.dart';

part 'tenant_model.freezed.dart';
part 'tenant_model.g.dart';

/// Represents a tenant occupying one of the landlord's properties.
@freezed
class Tenant with _$Tenant {
  const factory Tenant({
    required String id,
    required String landlordId,
    String? propertyId,
    required String fullName,
    String? email,
    String? phone,
    DateTime? leaseStart,
    DateTime? leaseEnd,
    required double rentAmount,
    double? depositAmount,
    String? leaseDocumentUrl,
    DateTime? createdAt,
  }) = _Tenant;

  factory Tenant.fromJson(Map<String, dynamic> json) =>
      _$TenantFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'tenant_model.freezed.dart';
part 'tenant_model.g.dart';

/// Represents a tenant occupying a unit in the landlord's property.
@freezed
class Tenant with _$Tenant {
  const factory Tenant({
    required String id,
    required String landlordId,
    String? unitId,
    required String fullName,
    String? email,
    String? phone,
    String? idNumber,
    DateTime? leaseStart,
    DateTime? leaseEnd,
    required double rentAmount,
    double? depositAmount,
    @Default('monthly') String paymentFrequency,
    String? photoUrl,
    String? idPhotoUrl,
    String? leaseDocumentUrl,
    String? notes,
    DateTime? createdAt,
  }) = _Tenant;

  factory Tenant.fromJson(Map<String, dynamic> json) => _$TenantFromJson(json);
}

/// Allowed payment frequencies.
abstract final class PaymentFrequencies {
  static const all = ['monthly', 'quarterly', 'biannual', 'annual'];

  static String label(String freq) => switch (freq) {
    'monthly' => 'Mensuel',
    'quarterly' => 'Trimestriel',
    'biannual' => 'Semestriel',
    'annual' => 'Annuel',
    _ => freq,
  };
}

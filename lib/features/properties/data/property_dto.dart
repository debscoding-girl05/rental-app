import 'package:landlord_os/features/properties/domain/property_model.dart';

/// Maps between Supabase row format and [Property] domain model.
class PropertyDto {
  const PropertyDto._();

  /// Converts a Supabase row (snake_case) to a [Property].
  static Property fromRow(Map<String, dynamic> row) {
    return Property(
      id: row['id'] as String,
      landlordId: row['landlord_id'] as String,
      name: row['name'] as String,
      propertyType: row['property_type'] as String? ?? 'immeuble',
      address: row['address'] as String,
      quartier: row['quartier'] as String?,
      city: row['city'] as String,
      country: row['country'] as String,
      floors: row['floors'] as int? ?? 1,
      totalUnits: row['total_units'] as int? ?? 1,
      purchasePrice: (row['purchase_price'] as num?)?.toDouble(),
      mortgageMonthly: (row['mortgage_monthly'] as num?)?.toDouble(),
      currency: row['currency'] as String? ?? 'XOF',
      notes: row['notes'] as String?,
      photos: (row['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : null,
    );
  }

  /// Converts a [Property] to a Supabase row (snake_case).
  static Map<String, dynamic> toRow(Property property) {
    return {
      'landlord_id': property.landlordId,
      'name': property.name,
      'property_type': property.propertyType,
      'address': property.address,
      'quartier': property.quartier,
      'city': property.city,
      'country': property.country,
      'floors': property.floors,
      'total_units': property.totalUnits,
      'purchase_price': property.purchasePrice,
      'mortgage_monthly': property.mortgageMonthly,
      'currency': property.currency,
      'notes': property.notes,
      'photos': property.photos,
    };
  }
}

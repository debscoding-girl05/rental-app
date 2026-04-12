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
      address: row['address'] as String,
      city: row['city'] as String,
      country: row['country'] as String,
      bedrooms: row['bedrooms'] as int?,
      bathrooms: row['bathrooms'] as int?,
      sizeSqm: (row['size_sqm'] as num?)?.toDouble(),
      purchasePrice: (row['purchase_price'] as num?)?.toDouble(),
      mortgageMonthly: (row['mortgage_monthly'] as num?)?.toDouble(),
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
  /// Omits `id` and `created_at` (set by the database).
  static Map<String, dynamic> toRow(Property property) {
    return {
      'landlord_id': property.landlordId,
      'name': property.name,
      'address': property.address,
      'city': property.city,
      'country': property.country,
      'bedrooms': property.bedrooms,
      'bathrooms': property.bathrooms,
      'size_sqm': property.sizeSqm,
      'purchase_price': property.purchasePrice,
      'mortgage_monthly': property.mortgageMonthly,
      'notes': property.notes,
      'photos': property.photos,
    };
  }
}

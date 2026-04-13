import 'package:landlord_os/features/properties/domain/unit_model.dart';

/// Maps between Supabase row format and [Unit] domain model.
class UnitDto {
  const UnitDto._();

  static Unit fromRow(Map<String, dynamic> row) {
    return Unit(
      id: row['id'] as String,
      landlordId: row['landlord_id'] as String,
      propertyId: row['property_id'] as String,
      unitLabel: row['unit_label'] as String,
      floorNumber: row['floor_number'] as int? ?? 0,
      unitType: row['unit_type'] as String? ?? 'chambre',
      bedrooms: row['bedrooms'] as int?,
      bathrooms: row['bathrooms'] as int?,
      sizeSqm: (row['size_sqm'] as num?)?.toDouble(),
      rentAmount: (row['rent_amount'] as num?)?.toDouble() ?? 0,
      isOccupied: row['is_occupied'] as bool? ?? false,
      photoUrl: row['photo_url'] as String?,
      notes: row['notes'] as String?,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : null,
    );
  }

  static Map<String, dynamic> toRow(Unit unit) {
    return {
      'landlord_id': unit.landlordId,
      'property_id': unit.propertyId,
      'unit_label': unit.unitLabel,
      'floor_number': unit.floorNumber,
      'unit_type': unit.unitType,
      'bedrooms': unit.bedrooms,
      'bathrooms': unit.bathrooms,
      'size_sqm': unit.sizeSqm,
      'rent_amount': unit.rentAmount,
      'is_occupied': unit.isOccupied,
      'photo_url': unit.photoUrl,
      'notes': unit.notes,
    };
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'unit_model.freezed.dart';
part 'unit_model.g.dart';

/// Represents a rentable unit (chambre, appartement, boutique) within a property.
@freezed
class Unit with _$Unit {
  const factory Unit({
    required String id,
    required String landlordId,
    required String propertyId,
    required String unitLabel,
    @Default(0) int floorNumber,
    @Default('chambre') String unitType,
    int? bedrooms,
    int? bathrooms,
    double? sizeSqm,
    @Default(0) double rentAmount,
    @Default(false) bool isOccupied,
    String? photoUrl,
    String? notes,
    DateTime? createdAt,
  }) = _Unit;

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);
}

/// Allowed unit types.
abstract final class UnitTypes {
  static const all = [
    'appartement',
    'chambre',
    'studio',
    'boutique',
    'bureau',
    'magasin',
    'garage',
    'other',
  ];

  static String label(String type) => switch (type) {
    'appartement' => 'Appartement',
    'chambre' => 'Chambre',
    'studio' => 'Studio',
    'boutique' => 'Boutique',
    'bureau' => 'Bureau',
    'magasin' => 'Magasin',
    'garage' => 'Garage',
    _ => 'Autre',
  };
}

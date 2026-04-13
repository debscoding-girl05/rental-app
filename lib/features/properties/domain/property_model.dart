import 'package:freezed_annotation/freezed_annotation.dart';

part 'property_model.freezed.dart';
part 'property_model.g.dart';

/// Represents a rental property (immeuble, compound, maison, etc.).
@freezed
class Property with _$Property {
  const factory Property({
    required String id,
    required String landlordId,
    required String name,
    @Default('immeuble') String propertyType,
    required String address,
    String? quartier,
    required String city,
    required String country,
    @Default(1) int floors,
    @Default(1) int totalUnits,
    double? purchasePrice,
    double? mortgageMonthly,
    @Default('XOF') String currency,
    String? notes,
    @Default([]) List<String> photos,
    DateTime? createdAt,
  }) = _Property;

  factory Property.fromJson(Map<String, dynamic> json) =>
      _$PropertyFromJson(json);
}

/// Allowed property types.
abstract final class PropertyTypes {
  static const all = [
    'immeuble',
    'compound',
    'maison',
    'studio',
    'duplex',
    'villa',
    'commercial',
    'terrain',
    'other',
  ];

  static String label(String type) => switch (type) {
        'immeuble' => 'Immeuble',
        'compound' => 'Concession / Compound',
        'maison' => 'Maison',
        'studio' => 'Studio',
        'duplex' => 'Duplex',
        'villa' => 'Villa',
        'commercial' => 'Local commercial',
        'terrain' => 'Terrain',
        _ => 'Autre',
      };
}

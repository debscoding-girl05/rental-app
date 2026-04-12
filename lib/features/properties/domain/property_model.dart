import 'package:freezed_annotation/freezed_annotation.dart';

part 'property_model.freezed.dart';
part 'property_model.g.dart';

/// Represents a rental property in the landlord's portfolio.
@freezed
class Property with _$Property {
  const factory Property({
    required String id,
    required String landlordId,
    required String name,
    required String address,
    required String city,
    required String country,
    int? bedrooms,
    int? bathrooms,
    double? sizeSqm,
    double? purchasePrice,
    double? mortgageMonthly,
    String? notes,
    @Default([]) List<String> photos,
    DateTime? createdAt,
  }) = _Property;

  factory Property.fromJson(Map<String, dynamic> json) =>
      _$PropertyFromJson(json);
}

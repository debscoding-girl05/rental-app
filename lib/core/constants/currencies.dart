/// Supported currencies with focus on African markets.
class Currency {
  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    this.decimalDigits = 2,
  });

  final String code;
  final String name;
  final String symbol;
  final int decimalDigits;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Currency && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$code — $name';
}

/// All supported currencies, African-first.
abstract final class Currencies {
  static const List<Currency> all = [
    // West Africa (CFA BCEAO zone) — 0 decimals
    Currency(
      code: 'XOF',
      name: 'Franc CFA (BCEAO)',
      symbol: 'FCFA',
      decimalDigits: 0,
    ),
    // Central Africa (CFA BEAC zone) — 0 decimals
    Currency(
      code: 'XAF',
      name: 'Franc CFA (BEAC)',
      symbol: 'FCFA',
      decimalDigits: 0,
    ),
    // Nigeria
    Currency(code: 'NGN', name: 'Naira nigérian', symbol: '₦'),
    // Ghana
    Currency(code: 'GHS', name: 'Cedi ghanéen', symbol: 'GH₵'),
    // Kenya
    Currency(code: 'KES', name: 'Shilling kényan', symbol: 'KSh'),
    // South Africa
    Currency(code: 'ZAR', name: 'Rand sud-africain', symbol: 'R'),
    // Morocco
    Currency(code: 'MAD', name: 'Dirham marocain', symbol: 'MAD'),
    // Egypt
    Currency(code: 'EGP', name: 'Livre égyptienne', symbol: 'E£'),
    // Tanzania
    Currency(code: 'TZS', name: 'Shilling tanzanien', symbol: 'TSh'),
    // Uganda — 0 decimals
    Currency(
      code: 'UGX',
      name: 'Shilling ougandais',
      symbol: 'USh',
      decimalDigits: 0,
    ),
    // Ethiopia
    Currency(code: 'ETB', name: 'Birr éthiopien', symbol: 'Br'),
    // Rwanda — 0 decimals
    Currency(
      code: 'RWF',
      name: 'Franc rwandais',
      symbol: 'FRw',
      decimalDigits: 0,
    ),
    // DRC — 0 decimals
    Currency(
      code: 'CDF',
      name: 'Franc congolais',
      symbol: 'FC',
      decimalDigits: 0,
    ),
    // Madagascar — 0 decimals
    Currency(
      code: 'MGA',
      name: 'Ariary malgache',
      symbol: 'Ar',
      decimalDigits: 0,
    ),
    // International
    Currency(code: 'EUR', name: 'Euro', symbol: '€'),
    Currency(code: 'USD', name: 'Dollar américain', symbol: '\$'),
    Currency(code: 'GBP', name: 'Livre sterling', symbol: '£'),
  ];

  /// Find a currency by ISO code.
  static Currency fromCode(String code) {
    return all.firstWhere((c) => c.code == code, orElse: () => all.first);
  }
}

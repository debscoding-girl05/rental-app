import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/constants/currencies.dart';

/// Manages the user's preferred currency.
///
/// Reads from Supabase user_metadata on init, persists changes back.
class CurrencyNotifier extends StateNotifier<Currency> {
  CurrencyNotifier() : super(_resolveInitial());

  static Currency _resolveInitial() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final code = user?.userMetadata?['preferred_currency'] as String?;
      if (code != null) return Currencies.fromCode(code);
    } catch (_) {}
    return Currencies.fromCode('XOF');
  }

  Future<void> setCurrency(String code) async {
    final currency = Currencies.fromCode(code);
    state = currency;
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'preferred_currency': code}),
      );
    } catch (_) {
      // Silently fail — state is already updated locally.
    }
  }
}

/// Provider for the user's selected currency.
final currencyProvider = StateNotifierProvider<CurrencyNotifier, Currency>(
  (ref) => CurrencyNotifier(),
);

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supported locales for LandlordOS.
const supportedLocales = [
  Locale('en'),
  Locale('fr'),
];

/// A [StateNotifier] that manages the current app locale.
///
/// Defaults to the system locale if it is one of the supported locales,
/// otherwise falls back to English.
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(_resolveInitialLocale());

  static Locale _resolveInitialLocale() {
    final systemLocale = ui.PlatformDispatcher.instance.locale;
    final languageCode = systemLocale.languageCode;

    // Check if the system language is one we support.
    for (final locale in supportedLocales) {
      if (locale.languageCode == languageCode) {
        return locale;
      }
    }

    // Fallback to English.
    return const Locale('en');
  }

  /// Switch the app locale to the given language code ('en' or 'fr').
  void setLocale(String languageCode) {
    for (final locale in supportedLocales) {
      if (locale.languageCode == languageCode) {
        state = locale;
        return;
      }
    }
  }

  /// Toggle between English and French.
  void toggleLocale() {
    if (state.languageCode == 'en') {
      state = const Locale('fr');
    } else {
      state = const Locale('en');
    }
  }
}

/// Provider for the current locale.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);

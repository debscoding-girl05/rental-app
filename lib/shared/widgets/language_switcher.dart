import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:landlord_os/core/providers/locale_provider.dart';

/// A compact language toggle widget that switches between English and French.
///
/// Displays a segmented-button style toggle showing "EN" and "FR".
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return SegmentedButton<String>(
      segments: const [
        ButtonSegment<String>(value: 'en', label: Text('EN')),
        ButtonSegment<String>(value: 'fr', label: Text('FR')),
      ],
      selected: {locale.languageCode},
      onSelectionChanged: (selection) {
        ref.read(localeProvider.notifier).setLocale(selection.first);
      },
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: WidgetStatePropertyAll(
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
      ),
    );
  }
}

/// A dropdown variant of the language switcher for use in settings screens.
class LanguageDropdown extends ConsumerWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return DropdownButton<String>(
      value: locale.languageCode,
      underline: const SizedBox.shrink(),
      items: const [
        DropdownMenuItem(value: 'en', child: Text('English')),
        DropdownMenuItem(value: 'fr', child: Text('Français')),
      ],
      onChanged: (value) {
        if (value != null) {
          ref.read(localeProvider.notifier).setLocale(value);
        }
      },
    );
  }
}

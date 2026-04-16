import 'package:flutter/widgets.dart';
import 'package:landlord_os/l10n/app_localizations.dart';

/// Convenience extension so screens can write `context.l10n.someKey`
/// instead of `AppLocalizations.of(context)!.someKey`.
extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

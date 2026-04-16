import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/constants/currencies.dart';
import 'package:landlord_os/core/providers/currency_provider.dart';
import 'package:landlord_os/core/providers/locale_provider.dart';
import 'package:landlord_os/core/extensions/l10n_ext.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currency = ref.watch(currencyProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settings)),
      body: ListView(
        children: [
          // --- Profile Section ---
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(
              Supabase
                          .instance
                          .client
                          .auth
                          .currentUser
                          ?.userMetadata?['full_name']
                      as String? ??
                  context.l10n.profile,
            ),
            subtitle: Text(
              Supabase.instance.client.auth.currentUser?.email ?? '',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile'),
          ),
          const Divider(),

          // --- Currency ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              context.l10n.preferences,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.monetization_on_outlined),
            title: Text(context.l10n.currency),
            subtitle: Text('${currency.symbol} — ${currency.name}'),
            onTap: () => _showCurrencyPicker(context, ref),
          ),

          // --- Language ---
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(context.l10n.language),
            subtitle: Text(
              locale.languageCode == 'fr' ? 'Fran\u00e7ais' : 'English',
            ),
            onTap: () {
              ref.read(localeProvider.notifier).toggleLocale();
            },
          ),
          const Divider(),

          // --- Sign Out ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              context.l10n.account,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              context.l10n.signOut,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(context.l10n.signOut),
                  content: Text(context.l10n.areYouSure),
                  actions: [
                    TextButton(
                      onPressed: () => ctx.pop(false),
                      child: Text(context.l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => ctx.pop(true),
                      child: Text(context.l10n.signOut),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    final current = ref.read(currencyProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                context.l10n.chooseCurrency,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: Currencies.all.length,
                itemBuilder: (_, index) {
                  final c = Currencies.all[index];
                  final isSelected = c.code == current.code;
                  return ListTile(
                    leading: Text(
                      c.symbol,
                      style: const TextStyle(fontSize: 18),
                    ),
                    title: Text(c.name),
                    subtitle: Text(c.code),
                    trailing: isSelected
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    selected: isSelected,
                    onTap: () {
                      ref.read(currencyProvider.notifier).setCurrency(c.code);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

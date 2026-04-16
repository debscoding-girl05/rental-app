import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/constants/currencies.dart';
import 'package:landlord_os/core/providers/currency_provider.dart';
import 'package:landlord_os/core/providers/locale_provider.dart';
import 'package:landlord_os/core/extensions/l10n_ext.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = Supabase.instance.client.auth.currentUser;
  }

  Future<void> _refreshUser() async {
    await Supabase.instance.client.auth.refreshSession();
    setState(() {
      _user = Supabase.instance.client.auth.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = ref.watch(currencyProvider);
    final locale = ref.watch(localeProvider);
    final avatarUrl = _user?.userMetadata?['avatar_url'] as String?;
    final fullName = _user?.userMetadata?['full_name'] as String?;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settings)),
      body: ListView(
        children: [
          // --- Profile Section ---
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null ? const Icon(Icons.person) : null,
            ),
            title: Text(fullName ?? context.l10n.profile),
            subtitle: Text(_user?.email ?? ''),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await context.push('/profile');
              _refreshUser();
            },
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
            onTap: () => _showCurrencyPicker(context),
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

  void _showCurrencyPicker(BuildContext context) {
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

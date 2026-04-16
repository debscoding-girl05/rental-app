import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/providers/locale_provider.dart';
import 'package:landlord_os/core/theme/app_theme.dart';
import 'package:landlord_os/core/theme/dark_theme.dart';
import 'package:landlord_os/l10n/app_localizations.dart';
import 'package:landlord_os/features/auth/presentation/login_screen.dart';
import 'package:landlord_os/features/auth/presentation/signup_screen.dart';
import 'package:landlord_os/features/dashboard/presentation/dashboard_screen.dart';
import 'package:landlord_os/features/properties/presentation/properties_screen.dart';
import 'package:landlord_os/features/properties/presentation/property_detail_screen.dart';
import 'package:landlord_os/features/properties/presentation/add_property_screen.dart';
import 'package:landlord_os/features/properties/presentation/add_unit_screen.dart';
import 'package:landlord_os/features/tenants/presentation/tenants_screen.dart';
import 'package:landlord_os/features/tenants/presentation/tenant_detail_screen.dart';
import 'package:landlord_os/features/tenants/presentation/add_tenant_screen.dart';
import 'package:landlord_os/features/financials/presentation/financials_screen.dart';
import 'package:landlord_os/features/financials/presentation/add_transaction_screen.dart';
import 'package:landlord_os/features/auth/presentation/forgot_password_screen.dart';
import 'package:landlord_os/features/ai/presentation/ai_assistant_screen.dart';
import 'package:landlord_os/features/ai/presentation/price_predictor_screen.dart';
import 'package:landlord_os/features/ai/presentation/profitability_screen.dart';
import 'package:landlord_os/features/maintenance/presentation/maintenance_screen.dart';
import 'package:landlord_os/features/maintenance/presentation/add_request_screen.dart';
import 'package:landlord_os/features/maintenance/presentation/maintenance_detail_screen.dart';
import 'package:landlord_os/features/settings/presentation/settings_screen.dart';
import 'package:landlord_os/features/profile/presentation/profile_screen.dart';

/// Root widget for LandlordOS.
class LandlordOSApp extends ConsumerWidget {
  const LandlordOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'LandlordOS',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}

/// Shell for the bottom navigation bar.
class _AppShell extends StatelessWidget {
  const _AppShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.navDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.home_work_outlined),
            selectedIcon: const Icon(Icons.home_work),
            label: l10n.navProperties,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: l10n.navTenants,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet),
            label: l10n.navFinancials,
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_awesome_outlined),
            selectedIcon: const Icon(Icons.auto_awesome),
            label: l10n.navAI,
          ),
        ],
      ),
    );
  }
}

/// Returns `true` if there is a logged-in Supabase user.
bool _isAuthenticated() {
  try {
    return Supabase.instance.client.auth.currentUser != null;
  } catch (_) {
    return false;
  }
}

final _router = GoRouter(
  initialLocation: '/dashboard',
  redirect: (context, state) {
    final loggedIn = _isAuthenticated();
    final isAuthRoute =
        state.matchedLocation == '/login' || state.matchedLocation == '/signup';

    if (!loggedIn && !isAuthRoute) return '/login';
    if (loggedIn && isAuthRoute) return '/dashboard';
    return null;
  },
  routes: [
    // Auth routes (no bottom nav)
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Maintenance routes (no bottom nav)
    GoRoute(
      path: '/maintenance',
      builder: (context, state) => const MaintenanceScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddRequestScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) => MaintenanceDetailScreen(
            maintenanceId: state.pathParameters['id']!,
          ),
        ),
      ],
    ),

    // Settings & Profile (no bottom nav)
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),

    // Main app shell with bottom nav
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _AppShell(navigationShell: navigationShell),
      branches: [
        // Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),

        // Properties
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/properties',
              builder: (context, state) => const PropertiesScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const AddPropertyScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) => PropertyDetailScreen(
                    propertyId: state.pathParameters['id']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'units/add',
                      builder: (context, state) => AddUnitScreen(
                        propertyId: state.pathParameters['id']!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // Tenants
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tenants',
              builder: (context, state) => const TenantsScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const AddTenantScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      TenantDetailScreen(tenantId: state.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),

        // Financials
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/financials',
              builder: (context, state) => const FinancialsScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const AddTransactionScreen(),
                ),
              ],
            ),
          ],
        ),

        // AI
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ai/assistant',
              builder: (context, state) => const AiAssistantScreen(),
              routes: [
                GoRoute(
                  path: 'price-predictor',
                  builder: (context, state) => const PricePredictorScreen(),
                ),
                GoRoute(
                  path: 'profitability',
                  builder: (context, state) => const ProfitabilityScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

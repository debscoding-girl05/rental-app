import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/theme/app_theme.dart';
import 'package:landlord_os/core/theme/dark_theme.dart';
import 'package:landlord_os/features/auth/presentation/login_screen.dart';
import 'package:landlord_os/features/auth/presentation/signup_screen.dart';
import 'package:landlord_os/features/dashboard/presentation/dashboard_screen.dart';
import 'package:landlord_os/features/properties/presentation/properties_screen.dart';
import 'package:landlord_os/features/properties/presentation/property_detail_screen.dart';
import 'package:landlord_os/features/properties/presentation/add_property_screen.dart';
import 'package:landlord_os/features/tenants/presentation/tenants_screen.dart';
import 'package:landlord_os/features/tenants/presentation/tenant_detail_screen.dart';
import 'package:landlord_os/features/tenants/presentation/add_tenant_screen.dart';
import 'package:landlord_os/features/financials/presentation/financials_screen.dart';
import 'package:landlord_os/features/ai/presentation/ai_assistant_screen.dart';

/// Root widget for LandlordOS.
class LandlordOSApp extends ConsumerWidget {
  const LandlordOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'LandlordOS',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
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
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.home_work_outlined), selectedIcon: Icon(Icons.home_work), label: 'Properties'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Tenants'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Financials'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'AI'),
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
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
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
                  builder: (context, state) => TenantDetailScreen(
                    tenantId: state.pathParameters['id']!,
                  ),
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
            ),
          ],
        ),

        // AI
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ai/assistant',
              builder: (context, state) => const AiAssistantScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

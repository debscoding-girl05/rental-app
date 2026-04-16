import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/constants/app_colors.dart';
import 'package:landlord_os/core/extensions/datetime_ext.dart';
import 'package:landlord_os/core/extensions/l10n_ext.dart';
import 'package:landlord_os/core/extensions/num_ext.dart';
import 'package:landlord_os/core/services/notification_service.dart';
import 'package:landlord_os/features/financials/data/transaction_repository.dart';
import 'package:landlord_os/features/financials/presentation/financials_controller.dart';
import 'package:landlord_os/features/payments/presentation/payment_controller.dart';
import 'package:landlord_os/features/properties/data/unit_repository.dart';
import 'package:landlord_os/features/properties/presentation/property_controller.dart';
import 'package:landlord_os/features/tenants/presentation/tenant_controller.dart';
import 'package:landlord_os/features/maintenance/presentation/maintenance_controller.dart';
import 'package:landlord_os/core/providers/locale_provider.dart';
import 'package:landlord_os/shared/widgets/stat_card.dart';

/// Main dashboard showing portfolio overview metrics.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final propertiesAsync = ref.watch(propertyControllerProvider);
    final tenantsAsync = ref.watch(tenantControllerProvider);
    final txAsync = ref.watch(financialsControllerProvider);
    final paymentsAsync = ref.watch(paymentControllerProvider);
    final maintenanceAsync = ref.watch(maintenanceControllerProvider);

    // Reschedule rent reminders whenever tenant data loads/changes.
    ref.listen(tenantControllerProvider, (_, next) {
      next.whenData((tenants) {
        NotificationService.instance.rescheduleAllReminders(tenants);
      });
    });

    final user = Supabase.instance.client.auth.currentUser;
    final displayName =
        user?.userMetadata?['full_name'] as String? ??
        user?.email?.split('@').first ??
        'Landlord';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.helloUser(displayName), style: theme.textTheme.titleMedium),
            Text(
              DateTime.now().formatted,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        actions: [
          // Language toggle
          IconButton(
            icon: Text(
              ref.watch(localeProvider).languageCode.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            tooltip: 'Switch language',
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLocale();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: context.l10n.signOut,
            onPressed: () async {
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
              if (confirm == true) {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) context.go('/login');
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Portfolio Stats ---
          _PortfolioStats(
            propertiesAsync: propertiesAsync,
            tenantsAsync: tenantsAsync,
            ref: ref,
          ),
          const SizedBox(height: 24),

          // --- Financial Summary ---
          Text(context.l10n.financialOverview, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          txAsync.when(
            loading: () => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (transactions) {
              if (transactions.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        context.l10n.noTransactions,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              final repo = ref.read(transactionRepositoryProvider);
              final summary = repo.computeSummary(transactions);

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: context.l10n.income,
                          value: summary.totalIncome.toCurrency(),
                          icon: Icons.trending_up,
                          iconColor: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: context.l10n.totalExpenses,
                          value: summary.totalExpenses.toCurrency(),
                          icon: Icons.trending_down,
                          iconColor: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: context.l10n.netProfit,
                          value: summary.netProfit.toCurrency(),
                          icon: Icons.account_balance,
                          iconColor: summary.netProfit >= 0
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: context.l10n.profitMargin,
                          value: summary.profitMargin.toPercentage(),
                          icon: Icons.pie_chart_outline,
                          iconColor: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  if (summary.totalIncome > 0 || summary.totalExpenses > 0) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 160,
                      child: _MiniPieChart(
                        income: summary.totalIncome,
                        expenses: summary.totalExpenses,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // --- Recent Payments ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.l10n.recentPayments, style: theme.textTheme.titleMedium),
              TextButton(
                onPressed: () => context.go('/financials'),
                child: Text(context.l10n.viewAll),
              ),
            ],
          ),
          const SizedBox(height: 8),
          paymentsAsync.when(
            loading: () => const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (payments) {
              if (payments.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        context.l10n.noTransactions,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              final recent = payments.take(5).toList();
              return Column(
                children: recent.map((p) {
                  final isDeposit = p.type == 'deposit';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDeposit
                                ? Icons.savings_outlined
                                : Icons.receipt_long_outlined,
                            size: 20,
                            color: isDeposit
                                ? theme.colorScheme.tertiary
                                : theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.periodLabel ?? p.type.toUpperCase(),
                                  style: theme.textTheme.bodyMedium,
                                ),
                                Text(
                                  p.date.formatted,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            p.amount.toCurrency(symbol: 'FCFA '),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),

          // --- Maintenance Summary ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.l10n.maintenance, style: theme.textTheme.titleMedium),
              TextButton(
                onPressed: () => context.push('/maintenance'),
                child: Text(context.l10n.viewAll),
              ),
            ],
          ),
          const SizedBox(height: 8),
          maintenanceAsync.when(
            loading: () => const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (requests) {
              final openCount =
                  requests.where((r) => r.status == 'open').length;
              final urgentCount =
                  requests.where((r) => r.priority == 'urgent').length;
              return Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: context.l10n.statusOpen,
                      value: '$openCount',
                      icon: Icons.build_outlined,
                      iconColor: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: context.l10n.priorityUrgent,
                      value: '$urgentCount',
                      icon: Icons.warning_amber_outlined,
                      iconColor: AppColors.error,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // --- Quick Actions ---
          Text(context.l10n.quickActions, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          // Row 1
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.home_work_outlined,
                  label: context.l10n.addProperty,
                  color: theme.colorScheme.primary,
                  onTap: () => context.push('/properties/add'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.person_add_outlined,
                  label: context.l10n.addTenant,
                  color: theme.colorScheme.secondary,
                  onTap: () => context.push('/tenants/add'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.add_chart_outlined,
                  label: context.l10n.addTransaction,
                  color: theme.colorScheme.tertiary,
                  onTap: () => context.push('/financials/add'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.auto_awesome_outlined,
                  label: context.l10n.aiAssistant,
                  color: AppColors.info,
                  onTap: () => context.go('/ai/assistant'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.price_change_outlined,
                  label: context.l10n.pricePredictor,
                  color: AppColors.warning,
                  onTap: () => context.push('/ai/assistant/price-predictor'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.analytics_outlined,
                  label: context.l10n.profitabilityAnalysis,
                  color: AppColors.success,
                  onTap: () => context.push('/ai/assistant/profitability'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _PortfolioStats extends StatefulWidget {
  const _PortfolioStats({
    required this.propertiesAsync,
    required this.tenantsAsync,
    required this.ref,
  });

  final AsyncValue propertiesAsync;
  final AsyncValue tenantsAsync;
  final WidgetRef ref;

  @override
  State<_PortfolioStats> createState() => _PortfolioStatsState();
}

class _PortfolioStatsState extends State<_PortfolioStats> {
  int _totalUnits = 0;
  int _occupiedUnits = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    try {
      final units = await widget.ref.read(unitRepositoryProvider).getAll();
      if (mounted) {
        setState(() {
          _totalUnits = units.length;
          _occupiedUnits = units.where((u) => u.isOccupied).length;
          _loaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final propertyCount = widget.propertiesAsync.valueOrNull?.length ?? 0;
    final tenantCount = widget.tenantsAsync.valueOrNull?.length ?? 0;
    final occupancyRate = _totalUnits > 0
        ? (_occupiedUnits / _totalUnits * 100)
        : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: context.l10n.properties,
                value: '$propertyCount',
                icon: Icons.home_work_outlined,
                iconColor: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: context.l10n.tenants,
                value: '$tenantCount',
                icon: Icons.people_outlined,
                iconColor: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: context.l10n.units,
                value: _loaded ? '$_occupiedUnits / $_totalUnits' : '...',
                icon: Icons.door_front_door_outlined,
                iconColor: theme.colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: context.l10n.occupancy,
                value: _loaded ? occupancyRate.toPercentage() : '...',
                icon: Icons.bar_chart_outlined,
                iconColor: occupancyRate >= 80
                    ? AppColors.success
                    : occupancyRate >= 50
                    ? AppColors.warning
                    : AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniPieChart extends StatelessWidget {
  const _MiniPieChart({required this.income, required this.expenses});

  final double income;
  final double expenses;

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 32,
        sections: [
          PieChartSectionData(
            value: income,
            title: context.l10n.income,
            color: AppColors.success,
            radius: 42,
            titleStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: expenses,
            title: context.l10n.totalExpenses,
            color: AppColors.error,
            radius: 42,
            titleStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

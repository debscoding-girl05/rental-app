import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:landlord_os/core/constants/app_colors.dart';
import 'package:landlord_os/core/extensions/l10n_ext.dart';
import 'package:landlord_os/core/extensions/num_ext.dart';
import 'package:landlord_os/features/financials/data/transaction_repository.dart';
import 'package:landlord_os/features/financials/domain/financial_summary.dart';
import 'package:landlord_os/features/financials/presentation/financials_controller.dart';
import 'package:landlord_os/shared/widgets/empty_state_widget.dart';
import 'package:landlord_os/shared/widgets/error_widget.dart';
import 'package:landlord_os/shared/widgets/stat_card.dart';

/// Financial overview with income, expenses, and charts.
class FinancialsScreen extends ConsumerWidget {
  const FinancialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(financialsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Financials')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/financials/add'),
        child: const Icon(Icons.add),
      ),
      body: txAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(financialsControllerProvider),
        ),
        data: (transactions) {
          if (transactions.isEmpty) {
            return EmptyStateWidget(
              message: context.l10n.noTransactions,
              icon: Icons.account_balance_wallet_outlined,
              actionLabel: context.l10n.addTransaction,
              onAction: () => context.push('/financials/add'),
            );
          }

          final repo = ref.read(transactionRepositoryProvider);
          final summary = repo.computeSummary(transactions);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary cards
              _SummaryCards(summary: summary),
              const SizedBox(height: 24),

              // Income vs Expenses pie chart
              Text('Income vs Expenses', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: _IncomeExpensePieChart(summary: summary),
              ),
              const SizedBox(height: 24),

              // Expense breakdown bar chart
              if (summary.expensesByCategory.isNotEmpty) ...[
                Text('Expense Breakdown', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: _ExpenseBarChart(expenses: summary.expensesByCategory),
                ),
                const SizedBox(height: 24),
              ],

              // Recent transactions list
              Text('Recent Transactions', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...transactions.take(10).map((tx) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: tx.type == 'income'
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1),
                      child: Icon(
                        tx.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                        color: tx.type == 'income' ? AppColors.success : AppColors.error,
                        size: 20,
                      ),
                    ),
                    title: Text(tx.category.replaceAll('_', ' ').toUpperCase(),
                        style: Theme.of(context).textTheme.bodyMedium),
                    subtitle: tx.description != null ? Text(tx.description!) : null,
                    trailing: Text(
                      '${tx.type == 'income' ? '+' : '-'}${tx.amount.toCurrency()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: tx.type == 'income' ? AppColors.success : AppColors.error,
                          ),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary});

  final FinancialSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: context.l10n.totalIncome,
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
                iconColor: summary.netProfit >= 0 ? AppColors.success : AppColors.error,
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
      ],
    );
  }
}

class _IncomeExpensePieChart extends StatelessWidget {
  const _IncomeExpensePieChart({required this.summary});

  final FinancialSummary summary;

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            value: summary.totalIncome,
            title: context.l10n.income,
            color: AppColors.success,
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          PieChartSectionData(
            value: summary.totalExpenses,
            title: context.l10n.expense,
            color: AppColors.error,
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ExpenseBarChart extends StatelessWidget {
  const _ExpenseBarChart({required this.expenses});

  final Map<String, double> expenses;

  static const _barColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.error,
    AppColors.warning,
    AppColors.info,
  ];

  @override
  Widget build(BuildContext context) {
    final entries = expenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: entries.first.value * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= entries.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    entries[idx].key.length > 6
                        ? '${entries[idx].key.substring(0, 6)}.'
                        : entries[idx].key,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: entries.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value,
                color: _barColors[e.key % _barColors.length],
                width: 24,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:landlord_os/core/extensions/datetime_ext.dart';
import 'package:landlord_os/core/extensions/num_ext.dart';
import 'package:landlord_os/features/payments/domain/payment_model.dart';
import 'package:landlord_os/features/payments/presentation/payment_controller.dart';
import 'package:landlord_os/shared/widgets/empty_state_widget.dart';
import 'package:landlord_os/shared/widgets/error_widget.dart';

/// Shows payment history for a specific tenant.
class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({
    required this.tenantId,
    required this.tenantName,
    required this.currencySymbol,
    super.key,
  });

  final String tenantId;
  final String tenantName;
  final String currencySymbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(tenantPaymentsProvider(tenantId));
    final theme = Theme.of(context);
    final cs = currencySymbol;

    return Scaffold(
      appBar: AppBar(title: Text('Payments - $tenantName')),
      body: paymentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(tenantPaymentsProvider(tenantId)),
        ),
        data: (payments) {
          if (payments.isEmpty) {
            return const EmptyStateWidget(
              message: 'No payments recorded yet.',
              icon: Icons.payment_outlined,
            );
          }

          // Separate deposits from rent payments
          final deposits =
              payments.where((p) => p.type == 'deposit').toList();
          final rents = payments.where((p) => p.type != 'deposit').toList();

          final totalDeposits =
              deposits.fold<double>(0, (sum, p) => sum + p.amount);
          final totalRent =
              rents.fold<double>(0, (sum, p) => sum + p.amount);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total Deposits',
                      amount: totalDeposits.toCurrency(symbol: '$cs '),
                      icon: Icons.savings_outlined,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total Rent',
                      amount: totalRent.toCurrency(symbol: '$cs '),
                      icon: Icons.receipt_long_outlined,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Deposit section
              if (deposits.isNotEmpty) ...[
                Text('Deposits (Caution)',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ...deposits.map((p) => _PaymentTile(
                      payment: p,
                      currencySymbol: cs,
                    )),
                const SizedBox(height: 20),
              ],

              // Rent payment section
              Text('Rent Payments', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (rents.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No rent payments yet'),
                )
              else
                ...rents.map((p) => _PaymentTile(
                      payment: p,
                      currencySymbol: cs,
                    )),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              amount,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.payment,
    required this.currencySymbol,
  });

  final Payment payment;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDeposit = payment.type == 'deposit';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDeposit
              ? theme.colorScheme.tertiary.withValues(alpha: 0.1)
              : theme.colorScheme.secondary.withValues(alpha: 0.1),
          child: Icon(
            isDeposit ? Icons.savings_outlined : Icons.receipt_long_outlined,
            color: isDeposit
                ? theme.colorScheme.tertiary
                : theme.colorScheme.secondary,
            size: 20,
          ),
        ),
        title: Text(
          payment.periodLabel ?? PaymentTypes.label(payment.type),
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Text(
          '${payment.date.formatted} - ${PaymentMethods.label(payment.paymentMethod)}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Text(
          payment.amount.toCurrency(symbol: '$currencySymbol '),
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

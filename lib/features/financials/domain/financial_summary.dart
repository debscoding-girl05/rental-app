/// Aggregated financial metrics for a portfolio or property.
class FinancialSummary {
  const FinancialSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.incomeByCategory,
    required this.expensesByCategory,
  });

  final double totalIncome;
  final double totalExpenses;
  final Map<String, double> incomeByCategory;
  final Map<String, double> expensesByCategory;

  /// Net profit (income minus expenses).
  double get netProfit => totalIncome - totalExpenses;

  /// Profit margin as a percentage.
  double get profitMargin =>
      totalIncome > 0 ? (netProfit / totalIncome) * 100 : 0;
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class MonthComparisonWidget extends StatelessWidget {
  final Map<String, dynamic> comparisonData;
  final String month1Name;
  final String month2Name;

  const MonthComparisonWidget({
    Key? key,
    required this.comparisonData,
    required this.month1Name,
    required this.month2Name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final total1 = comparisonData['month1Total'] as double;
    final total2 = comparisonData['month2Total'] as double;
    final difference = comparisonData['difference'] as double;
    final percentageChange = comparisonData['percentageChange'] as double;
    final categoryTotals1 = comparisonData['categoryTotals1'] as Map<String, double>;
    final categoryTotals2 = comparisonData['categoryTotals2'] as Map<String, double>;

    final isIncrease = difference > 0;
    final changeColor = isIncrease ? Colors.red : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comparación Mensual',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 20),

        // Total comparison card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMonthTotal(context, month1Name, total1, currencyFormat),
                    Icon(
                      Icons.arrow_forward,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    _buildMonthTotal(context, month2Name, total2, currencyFormat),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: changeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: changeColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isIncrease ? Icons.trending_up : Icons.trending_down,
                        color: changeColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${isIncrease ? '+' : ''}${currencyFormat.format(difference)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: changeColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${percentageChange.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          fontSize: 14,
                          color: changeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Category comparison
        if (categoryTotals1.isNotEmpty || categoryTotals2.isNotEmpty) ...[
          Text(
            'Por Categoría',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _buildCategoryComparison(
            context,
            categoryTotals1,
            categoryTotals2,
            currencyFormat,
          ),
        ],
      ],
    );
  }

  Widget _buildMonthTotal(
    BuildContext context,
    String monthName,
    double total,
    NumberFormat format,
  ) {
    return Column(
      children: [
        Text(
          monthName,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          format.format(total),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryComparison(
    BuildContext context,
    Map<String, double> totals1,
    Map<String, double> totals2,
    NumberFormat format,
  ) {
    final allCategories = {...totals1.keys, ...totals2.keys}.toList();
    allCategories.sort();

    return Column(
      children: allCategories.map((category) {
        final amount1 = totals1[category] ?? 0.0;
        final amount2 = totals2[category] ?? 0.0;
        final diff = amount2 - amount1;
        final color = Color(Expense.categoryColors[category] ?? 0xFF999999);
        final icon = Expense.categoryIcons[category] ?? '📦';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(
                          format.format(amount1),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          format.format(amount2),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    if (diff != 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${diff > 0 ? '+' : ''}${format.format(diff)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: diff > 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

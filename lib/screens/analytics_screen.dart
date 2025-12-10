import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/database_service.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/trend_bar_chart.dart';
import '../widgets/trend_line_chart.dart';
import '../widgets/category_breakdown_widget.dart';
import '../widgets/month_comparison_widget.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _db = DatabaseService();
  late TabController _tabController;
  bool _isLoading = true;

  // Data variables
  Map<String, double> _categoryPercentages = {};
  Map<String, double> _monthlyTrend = {};
  Map<String, double> _categoryTotals = {};
  Map<String, dynamic> _monthComparison = {};
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Simulate loading delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1, 1);

      _categoryPercentages = _db.getCategoryPercentages();
      _monthlyTrend = _db.getMonthlyTrend(6);
      _categoryTotals = _db.getCategoryTotals();
      _totalAmount = _db.getMonthlyTotal();
      _monthComparison = _db.compareMonths(lastMonth, now);

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading analytics data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.pie_chart), text: 'Distribución'),
            Tab(icon: Icon(Icons.show_chart), text: 'Tendencias'),
            Tab(icon: Icon(Icons.table_chart), text: 'Reportes'),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: _loadData,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDistributionTab(),
                  _buildTrendsTab(),
                  _buildReportsTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando análisis...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distribución por Categoría',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mes actual',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 20),
                  ExpensePieChart(categoryPercentages: _categoryPercentages),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: CategoryBreakdownWidget(
                categoryTotals: _categoryTotals,
                totalAmount: _totalAmount,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: TrendBarChart(
                trendData: _monthlyTrend,
                title: 'Gastos Mensuales (Últimos 6 Meses)',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: TrendLineChart(
                trendData: _monthlyTrend,
                title: 'Evolución de Gastos',
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final currentMonthName = DateFormat('MMMM yyyy', 'es').format(now);
    final lastMonthName = DateFormat('MMMM yyyy', 'es').format(lastMonth);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: MonthComparisonWidget(
                comparisonData: _monthComparison,
                month1Name: lastMonthName.substring(0, 1).toUpperCase() +
                           lastMonthName.substring(1),
                month2Name: currentMonthName.substring(0, 1).toUpperCase() +
                           currentMonthName.substring(1),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSummaryCards(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final weekTotal = _db.getTotalByPeriod('week');
    final monthTotal = _db.getMonthlyTotal();
    final yearTotal = _db.getTotalByPeriod('year');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen Rápido',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Esta Semana',
                currencyFormat.format(weekTotal),
                Icons.calendar_today,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Este Mes',
                currencyFormat.format(monthTotal),
                Icons.calendar_month,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          context,
          'Este Año',
          currencyFormat.format(yearTotal),
          Icons.calendar_today_outlined,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final expenses = _db.getCurrentMonthExpenses();
    final avgExpense = expenses.isNotEmpty
        ? _totalAmount / expenses.length
        : 0.0;

    // Find top category
    String topCategory = 'N/A';
    double topAmount = 0.0;
    _categoryTotals.forEach((category, amount) {
      if (amount > topAmount) {
        topAmount = amount;
        topCategory = category;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas del Mes',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSummaryRow(
                  context,
                  'Total de Transacciones',
                  '${expenses.length}',
                  Icons.receipt_long,
                ),
                const Divider(height: 24),
                _buildSummaryRow(
                  context,
                  'Gasto Promedio',
                  currencyFormat.format(avgExpense),
                  Icons.analytics,
                ),
                const Divider(height: 24),
                _buildSummaryRow(
                  context,
                  'Categoría Principal',
                  topCategory != 'N/A'
                      ? '${Expense.categoryIcons[topCategory] ?? ''} $topCategory'
                      : topCategory,
                  Icons.star,
                ),
                const Divider(height: 24),
                _buildSummaryRow(
                  context,
                  'Gasto en Categoría Principal',
                  currencyFormat.format(topAmount),
                  Icons.trending_up,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

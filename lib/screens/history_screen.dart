import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/database_service.dart';
import '../widgets/expense_card.dart';
import 'add_edit_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _db = DatabaseService();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategory;
  String? _selectedPeriod;
  double _minAmount = 0;
  double _maxAmount = 10000;
  bool _useAmountFilter = false;

  List<Expense> _filteredExpenses = [];

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredExpenses = _db.getFilteredExpenses(
        startDate: _startDate,
        endDate: _endDate,
        category: _selectedCategory,
        minAmount: _useAmountFilter ? _minAmount : null,
        maxAmount: _useAmountFilter ? _maxAmount : null,
      );
    });
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedCategory = null;
      _selectedPeriod = null;
      _useAmountFilter = false;
      _minAmount = 0;
      _maxAmount = 10000;
      _applyFilters();
    });
  }

  void _selectPeriod(String period) {
    setState(() {
      _selectedPeriod = period;
      final now = DateTime.now();

      switch (period) {
        case 'Hoy':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = now;
          break;
        case 'Semana':
          _startDate = now.subtract(Duration(days: now.weekday - 1));
          _startDate = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
          _endDate = now;
          break;
        case 'Mes':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = now;
          break;
        case 'Año':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = now;
          break;
      }
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Gastos'),
      ),
      body: Column(
        children: [
          _buildQuickPeriodFilters(),
          _buildFilterSection(),
          _buildSummaryBar(total, currencyFormat),
          Expanded(
            child: _filteredExpenses.isEmpty
                ? _buildEmptyState()
                : _buildExpenseList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPeriodFilters() {
    final periods = ['Hoy', 'Semana', 'Mes', 'Año'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: periods.map((period) {
            final isSelected = _selectedPeriod == period;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(period),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    _selectPeriod(period);
                  } else {
                    setState(() {
                      _selectedPeriod = null;
                      _startDate = null;
                      _endDate = null;
                      _applyFilters();
                    });
                  }
                },
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtros Avanzados',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_startDate != null || _endDate != null || _selectedCategory != null || _useAmountFilter)
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Limpiar'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Date Range Filter
            if (_selectedPeriod == null) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildDateButton(
                      label: 'Desde',
                      date: _startDate,
                      onPressed: () => _selectStartDate(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateButton(
                      label: 'Hasta',
                      date: _endDate,
                      onPressed: () => _selectEndDate(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Category Filter
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Categoría',
                prefixIcon: Icon(
                  Icons.filter_list,
                  color: Theme.of(context).colorScheme.primary,
                ),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Todas las categorías'),
                ),
                ...Expense.categories.map((category) {
                  final icon = Expense.categoryIcons[category] ?? '📦';
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text('$icon $category'),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _applyFilters();
                });
              },
            ),

            const SizedBox(height: 16),

            // Amount Range Filter
            Row(
              children: [
                Checkbox(
                  value: _useAmountFilter,
                  onChanged: (value) {
                    setState(() {
                      _useAmountFilter = value ?? false;
                      _applyFilters();
                    });
                  },
                ),
                Text(
                  'Filtrar por monto',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),

            if (_useAmountFilter) ...[
              const SizedBox(height: 8),
              Text(
                'Rango: \$${_minAmount.toStringAsFixed(0)} - \$${_maxAmount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              RangeSlider(
                values: RangeValues(_minAmount, _maxAmount),
                min: 0,
                max: 10000,
                divisions: 100,
                labels: RangeLabels(
                  '\$${_minAmount.toStringAsFixed(0)}',
                  '\$${_maxAmount.toStringAsFixed(0)}',
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    _minAmount = values.start;
                    _maxAmount = values.end;
                    _applyFilters();
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onPressed,
  }) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.calendar_today, size: 18),
      label: Text(
        date == null ? label : dateFormat.format(date),
        style: const TextStyle(fontSize: 14),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _buildSummaryBar(double total, NumberFormat currencyFormat) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_filteredExpenses.length} gastos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
          Text(
            'Total: ${currencyFormat.format(total)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredExpenses.length,
      itemBuilder: (context, index) {
        final expense = _filteredExpenses[index];
        return ExpenseCard(
          expense: expense,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditScreen(expense: expense),
              ),
            ).then((_) => _applyFilters());
          },
          onDelete: () {
            _db.deleteExpense(expense.id);
            _applyFilters();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gasto eliminado')),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron gastos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta ajustar los filtros',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: _endDate ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        _selectedPeriod = null; // Clear period selection
        _applyFilters();
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
        _selectedPeriod = null; // Clear period selection
        _applyFilters();
      });
    }
  }
}

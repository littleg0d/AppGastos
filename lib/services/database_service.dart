import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../models/expense.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const String _boxName = 'expenses';
  Box<Expense>? _expenseBox;

  // Initialize the database
  Future<void> init() async {
    try {
      _expenseBox = await Hive.openBox<Expense>(_boxName);
      debugPrint('✅ Database initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing database: $e');
      rethrow;
    }
  }

  Box<Expense> get _box {
    if (_expenseBox == null || !_expenseBox!.isOpen) {
      throw Exception('Database not initialized. Call init() first.');
    }
    return _expenseBox!;
  }

  // Logging helper
  void _logError(String operation, dynamic error) {
    debugPrint('❌ Database Error [$operation]: $error');
  }

  // CREATE - Add a new expense
  Future<void> addExpense(Expense expense) async {
    try {
      await _box.put(expense.id, expense);
      debugPrint('✅ Expense added: ${expense.id}');
    } catch (e) {
      _logError('addExpense', e);
      rethrow;
    }
  }

  // READ - Get all expenses
  List<Expense> getAllExpenses() {
    try {
      return _box.values.toList();
    } catch (e) {
      _logError('getAllExpenses', e);
      return [];
    }
  }

  // READ - Get expense by ID
  Expense? getExpenseById(String id) {
    try {
      return _box.get(id);
    } catch (e) {
      _logError('getExpenseById', e);
      return null;
    }
  }

  // UPDATE - Update an existing expense
  Future<void> updateExpense(Expense expense) async {
    try {
      await _box.put(expense.id, expense);
      debugPrint('✅ Expense updated: ${expense.id}');
    } catch (e) {
      _logError('updateExpense', e);
      rethrow;
    }
  }

  // DELETE - Remove an expense
  Future<void> deleteExpense(String id) async {
    try {
      await _box.delete(id);
      debugPrint('✅ Expense deleted: $id');
    } catch (e) {
      _logError('deleteExpense', e);
      rethrow;
    }
  }

  // Get expenses for current month
  List<Expense> getCurrentMonthExpenses() {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      return _box.values.where((expense) {
        return expense.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
            expense.date.isBefore(endOfMonth.add(const Duration(seconds: 1)));
      }).toList();
    } catch (e) {
      _logError('getCurrentMonthExpenses', e);
      return [];
    }
  }

  // Get expenses for a specific month
  List<Expense> getExpensesForMonth(DateTime month) {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      return _box.values.where((expense) {
        return expense.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
            expense.date.isBefore(endOfMonth.add(const Duration(seconds: 1)));
      }).toList();
    } catch (e) {
      _logError('getExpensesForMonth', e);
      return [];
    }
  }

  // Get expenses by period (Today, Week, Month, Year)
  List<Expense> getExpensesByPeriod(String period) {
    try {
      final now = DateTime.now();
      DateTime startDate;

      switch (period.toLowerCase()) {
        case 'today':
        case 'hoy':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
        case 'semana':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          startDate = DateTime(startDate.year, startDate.month, startDate.day);
          break;
        case 'month':
        case 'mes':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'year':
        case 'año':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = DateTime(now.year, now.month, 1);
      }

      return _box.values.where((expense) {
        return expense.date.isAfter(startDate.subtract(const Duration(seconds: 1)));
      }).toList();
    } catch (e) {
      _logError('getExpensesByPeriod', e);
      return [];
    }
  }

  // Get weekly expenses
  List<Expense> getWeeklyExpenses() {
    return getExpensesByPeriod('week');
  }

  // Get yearly expenses
  List<Expense> getYearlyExpenses() {
    return getExpensesByPeriod('year');
  }

  // Get expenses by amount range
  List<Expense> getExpensesByAmountRange(double minAmount, double maxAmount) {
    try {
      return _box.values.where((expense) {
        return expense.amount >= minAmount && expense.amount <= maxAmount;
      }).toList();
    } catch (e) {
      _logError('getExpensesByAmountRange', e);
      return [];
    }
  }

  // Calculate monthly total
  double getMonthlyTotal() {
    try {
      final monthExpenses = getCurrentMonthExpenses();
      return monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    } catch (e) {
      _logError('getMonthlyTotal', e);
      return 0.0;
    }
  }

  // Get total for a specific period
  double getTotalByPeriod(String period) {
    try {
      final expenses = getExpensesByPeriod(period);
      return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    } catch (e) {
      _logError('getTotalByPeriod', e);
      return 0.0;
    }
  }

  // Get category totals for a date range
  Map<String, double> getCategoryTotals({DateTime? startDate, DateTime? endDate}) {
    try {
      var expenses = _box.values.toList();

      if (startDate != null) {
        expenses = expenses.where((e) =>
            e.date.isAfter(startDate.subtract(const Duration(seconds: 1)))).toList();
      }

      if (endDate != null) {
        expenses = expenses.where((e) =>
            e.date.isBefore(endDate.add(const Duration(days: 1)))).toList();
      }

      final Map<String, double> categoryTotals = {};
      for (var expense in expenses) {
        categoryTotals[expense.category] =
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }

      return categoryTotals;
    } catch (e) {
      _logError('getCategoryTotals', e);
      return {};
    }
  }

  // Get category percentages for current month
  Map<String, double> getCategoryPercentages() {
    try {
      final monthExpenses = getCurrentMonthExpenses();
      final total = monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

      if (total == 0) return {};

      final Map<String, double> categoryTotals = {};

      for (var expense in monthExpenses) {
        categoryTotals[expense.category] =
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }

      final Map<String, double> percentages = {};
      categoryTotals.forEach((category, amount) {
        percentages[category] = (amount / total) * 100;
      });

      return percentages;
    } catch (e) {
      _logError('getCategoryPercentages', e);
      return {};
    }
  }

  // Get monthly trend (spending for last N months)
  Map<String, double> getMonthlyTrend(int monthsBack) {
    try {
      final now = DateTime.now();
      final Map<String, double> trend = {};

      for (int i = monthsBack - 1; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final expenses = getExpensesForMonth(month);
        final total = expenses.fold(0.0, (sum, expense) => sum + expense.amount);

        // Format: "Ene 2024"
        final monthKey = '${_getMonthAbbreviation(month.month)} ${month.year}';
        trend[monthKey] = total;
      }

      return trend;
    } catch (e) {
      _logError('getMonthlyTrend', e);
      return {};
    }
  }

  // Compare two months
  Map<String, dynamic> compareMonths(DateTime month1, DateTime month2) {
    try {
      final expenses1 = getExpensesForMonth(month1);
      final expenses2 = getExpensesForMonth(month2);

      final total1 = expenses1.fold(0.0, (sum, expense) => sum + expense.amount);
      final total2 = expenses2.fold(0.0, (sum, expense) => sum + expense.amount);

      final difference = total2 - total1;
      final percentageChange = total1 > 0 ? ((difference / total1) * 100) : 0.0;

      final categoryTotals1 = <String, double>{};
      final categoryTotals2 = <String, double>{};

      for (var expense in expenses1) {
        categoryTotals1[expense.category] =
            (categoryTotals1[expense.category] ?? 0) + expense.amount;
      }

      for (var expense in expenses2) {
        categoryTotals2[expense.category] =
            (categoryTotals2[expense.category] ?? 0) + expense.amount;
      }

      return {
        'month1Total': total1,
        'month2Total': total2,
        'difference': difference,
        'percentageChange': percentageChange,
        'categoryTotals1': categoryTotals1,
        'categoryTotals2': categoryTotals2,
      };
    } catch (e) {
      _logError('compareMonths', e);
      return {
        'month1Total': 0.0,
        'month2Total': 0.0,
        'difference': 0.0,
        'percentageChange': 0.0,
        'categoryTotals1': <String, double>{},
        'categoryTotals2': <String, double>{},
      };
    }
  }

  // Get recent expenses (last N)
  List<Expense> getRecentExpenses({int count = 5}) {
    try {
      final allExpenses = _box.values.toList();
      allExpenses.sort((a, b) => b.date.compareTo(a.date));
      return allExpenses.take(count).toList();
    } catch (e) {
      _logError('getRecentExpenses', e);
      return [];
    }
  }

  // Get filtered expenses
  List<Expense> getFilteredExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    double? minAmount,
    double? maxAmount,
  }) {
    try {
      var expenses = _box.values.toList();

      if (startDate != null) {
        expenses = expenses.where((e) =>
            e.date.isAfter(startDate.subtract(const Duration(seconds: 1)))).toList();
      }

      if (endDate != null) {
        expenses = expenses.where((e) =>
            e.date.isBefore(endDate.add(const Duration(days: 1)))).toList();
      }

      if (category != null && category.isNotEmpty && category != 'Todas') {
        expenses = expenses.where((e) => e.category == category).toList();
      }

      if (minAmount != null) {
        expenses = expenses.where((e) => e.amount >= minAmount).toList();
      }

      if (maxAmount != null) {
        expenses = expenses.where((e) => e.amount <= maxAmount).toList();
      }

      expenses.sort((a, b) => b.date.compareTo(a.date));
      return expenses;
    } catch (e) {
      _logError('getFilteredExpenses', e);
      return [];
    }
  }

  // Get total expenses count
  int getExpenseCount() {
    try {
      return _box.length;
    } catch (e) {
      _logError('getExpenseCount', e);
      return 0;
    }
  }

  // Clear all expenses (for testing/reset)
  Future<void> clearAllExpenses() async {
    try {
      await _box.clear();
      debugPrint('✅ All expenses cleared');
    } catch (e) {
      _logError('clearAllExpenses', e);
      rethrow;
    }
  }

  // Close the database
  Future<void> close() async {
    try {
      await _box.close();
      debugPrint('✅ Database closed');
    } catch (e) {
      _logError('close', e);
    }
  }

  // Helper: Get month abbreviation in Spanish
  String _getMonthAbbreviation(int month) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return months[month - 1];
  }
}

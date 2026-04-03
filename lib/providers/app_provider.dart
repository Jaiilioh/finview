import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/budget_category.dart';
import '../models/savings_goal.dart';
import '../models/user_settings.dart';
import '../services/hive_service.dart';
import '../utils/constants.dart';

class AppProvider extends ChangeNotifier {
  final HiveService _hive = HiveService();
  final Uuid _uuid = const Uuid();

  List<Transaction> _transactions = [];
  List<BudgetCategory> _categories = [];
  List<SavingsGoal> _goals = [];
  late UserSettings _settings;

  // ─── Getters ───
  List<Transaction> get transactions => _transactions;
  List<BudgetCategory> get categories => _categories;
  List<SavingsGoal> get goals => _goals;
  UserSettings get settings => _settings;
  bool get onboardingCompleted => _settings.onboardingCompleted;

  List<Transaction> get currentMonthTransactions {
    final now = DateTime.now();
    return _transactions
        .where(
            (t) => t.date.year == now.year && t.date.month == now.month)
        .toList();
  }

  List<Transaction> get recentTransactions {
    final sorted = List<Transaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  double get totalIncome => _settings.monthlyIncome;

  double get totalSpent {
    return currentMonthTransactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalEarned {
    return currentMonthTransactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get remainingBalance => totalIncome - totalSpent;

  double get totalBudgetLimit =>
      _categories.fold(0.0, (sum, c) => sum + c.budgetLimit);

  int get budgetHealthScore {
    if (_categories.isEmpty || totalBudgetLimit == 0) return 100;

    double totalPenalty = 0;
    for (final cat in _categories) {
      final spent = getCategorySpent(cat.name);
      if (cat.budgetLimit > 0) {
        final ratio = spent / cat.budgetLimit;
        if (ratio > 1.0) {
          totalPenalty += (ratio - 1.0) * 30;
        } else if (ratio > 0.8) {
          totalPenalty += (ratio - 0.8) * 10;
        }
      }
    }
    return (100 - totalPenalty).clamp(0, 100).round();
  }

  int get streakDays => _settings.streakDays;

  double getCategorySpent(String categoryName) {
    return currentMonthTransactions
        .where((t) => t.category == categoryName && !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> get categorySpendingMap {
    final map = <String, double>{};
    for (final cat in _categories) {
      map[cat.name] = getCategorySpent(cat.name);
    }
    return map;
  }

  String? get weeklyNudge {
    if (_categories.isEmpty) return null;

    final now = DateTime.now();
    final daysLeft = DateTime(now.year, now.month + 1, 0).day - now.day;

    for (final cat in _categories) {
      final spent = getCategorySpent(cat.name);
      if (cat.budgetLimit > 0) {
        final pct = (spent / cat.budgetLimit * 100).round();
        if (pct >= 70 && pct < 100) {
          return "You've used $pct% of your ${cat.name} budget with $daysLeft days left this month";
        }
      }
    }
    return null;
  }

  // Best / worst categories for month-end recap
  String? get bestCategory {
    if (_categories.isEmpty) return null;
    BudgetCategory? best;
    double bestRatio = double.infinity;
    for (final cat in _categories) {
      if (cat.budgetLimit > 0) {
        final ratio = getCategorySpent(cat.name) / cat.budgetLimit;
        if (ratio < bestRatio) {
          bestRatio = ratio;
          best = cat;
        }
      }
    }
    return best?.name;
  }

  String? get worstCategory {
    if (_categories.isEmpty) return null;
    BudgetCategory? worst;
    double worstRatio = -1;
    for (final cat in _categories) {
      if (cat.budgetLimit > 0) {
        final ratio = getCategorySpent(cat.name) / cat.budgetLimit;
        if (ratio > worstRatio) {
          worstRatio = ratio;
          worst = cat;
        }
      }
    }
    return worst?.name;
  }

  double get netSavings => totalIncome - totalSpent;

  // ─── Init ───
  void loadData() {
    _transactions = _hive.getTransactions();
    _categories = _hive.getCategories();
    _goals = _hive.getGoals();
    _settings = _hive.getSettings();
    notifyListeners();
  }

  // ─── Onboarding ───
  Future<void> completeOnboarding(
      double income, List<BudgetCategory> cats) async {
    _settings.monthlyIncome = income;
    _settings.onboardingCompleted = true;
    await _hive.saveSettings(_settings);

    for (final c in cats) {
      await _hive.addCategory(c);
    }
    _categories = _hive.getCategories();
    notifyListeners();
  }

  List<BudgetCategory> generateDefaultCategories(double income) {
    return DefaultCategories.categories.map((c) {
      return BudgetCategory(
        id: _uuid.v4(),
        name: c['name'] as String,
        iconName: c['icon'] as String,
        budgetLimit:
            double.parse((income * (c['percentage'] as double)).toStringAsFixed(2)),
        colorValue: c['color'] as int,
      );
    }).toList();
  }

  // ─── Transactions ───
  Future<void> addTransaction(Transaction t) async {
    await _hive.addTransaction(t);
    _updateStreak(t.date);
    _transactions = _hive.getTransactions();
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction t) async {
    await _hive.updateTransaction(t);
    _transactions = _hive.getTransactions();
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _hive.deleteTransaction(id);
    _transactions = _hive.getTransactions();
    notifyListeners();
  }

  String newId() => _uuid.v4();

  void _updateStreak(DateTime transactionDate) {
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final txDay = DateTime(
        transactionDate.year, transactionDate.month, transactionDate.day);

    if (_settings.lastTransactionDate != null) {
      final lastDay = DateTime(
        _settings.lastTransactionDate!.year,
        _settings.lastTransactionDate!.month,
        _settings.lastTransactionDate!.day,
      );
      final diff = today.difference(lastDay).inDays;
      if (diff == 1) {
        _settings.streakDays++;
      } else if (diff > 1) {
        _settings.streakDays = 1;
      }
    } else {
      _settings.streakDays = 1;
    }
    _settings.lastTransactionDate = txDay;
    _hive.saveSettings(_settings);
  }

  // ─── Categories ───
  Future<void> addCategory(BudgetCategory c) async {
    await _hive.addCategory(c);
    _categories = _hive.getCategories();
    notifyListeners();
  }

  Future<void> updateCategory(BudgetCategory c) async {
    await _hive.updateCategory(c);
    _categories = _hive.getCategories();
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    await _hive.deleteCategory(id);
    _categories = _hive.getCategories();
    notifyListeners();
  }

  Future<void> updateIncome(double income) async {
    _settings.monthlyIncome = income;
    await _hive.saveSettings(_settings);
    notifyListeners();
  }

  // ─── Goals ───
  Future<void> addGoal(SavingsGoal g) async {
    await _hive.addGoal(g);
    _goals = _hive.getGoals();
    notifyListeners();
  }

  Future<void> updateGoal(SavingsGoal g) async {
    await _hive.updateGoal(g);
    _goals = _hive.getGoals();
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    await _hive.deleteGoal(id);
    _goals = _hive.getGoals();
    notifyListeners();
  }
}

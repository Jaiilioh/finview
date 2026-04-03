import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/budget_category.dart';
import '../models/savings_goal.dart';
import '../models/user_settings.dart';

class HiveService {
  static const String transactionsBox = 'transactions';
  static const String categoriesBox = 'categories';
  static const String goalsBox = 'goals';
  static const String settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(BudgetCategoryAdapter());
    Hive.registerAdapter(SavingsGoalAdapter());
    Hive.registerAdapter(UserSettingsAdapter());

    await Hive.openBox<Transaction>(transactionsBox);
    await Hive.openBox<BudgetCategory>(categoriesBox);
    await Hive.openBox<SavingsGoal>(goalsBox);
    await Hive.openBox<UserSettings>(settingsBox);
  }

  // ─── Transactions ───
  Box<Transaction> get transactionBox =>
      Hive.box<Transaction>(transactionsBox);

  List<Transaction> getTransactions() {
    final list = transactionBox.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<Transaction> getTransactionsForMonth(DateTime month) {
    return getTransactions()
        .where(
            (t) => t.date.year == month.year && t.date.month == month.month)
        .toList();
  }

  Future<void> addTransaction(Transaction t) async {
    await transactionBox.put(t.id, t);
  }

  Future<void> updateTransaction(Transaction t) async {
    await transactionBox.put(t.id, t);
  }

  Future<void> deleteTransaction(String id) async {
    await transactionBox.delete(id);
  }

  // ─── Categories ───
  Box<BudgetCategory> get categoryBox =>
      Hive.box<BudgetCategory>(categoriesBox);

  List<BudgetCategory> getCategories() {
    return categoryBox.values.toList();
  }

  Future<void> addCategory(BudgetCategory c) async {
    await categoryBox.put(c.id, c);
  }

  Future<void> updateCategory(BudgetCategory c) async {
    await categoryBox.put(c.id, c);
  }

  Future<void> deleteCategory(String id) async {
    await categoryBox.delete(id);
  }

  // ─── Goals ───
  Box<SavingsGoal> get goalBox => Hive.box<SavingsGoal>(goalsBox);

  List<SavingsGoal> getGoals() {
    return goalBox.values.toList();
  }

  Future<void> addGoal(SavingsGoal g) async {
    await goalBox.put(g.id, g);
  }

  Future<void> updateGoal(SavingsGoal g) async {
    await goalBox.put(g.id, g);
  }

  Future<void> deleteGoal(String id) async {
    await goalBox.delete(id);
  }

  // ─── Settings ───
  Box<UserSettings> get settingsBoxInstance =>
      Hive.box<UserSettings>(settingsBox);

  UserSettings getSettings() {
    return settingsBoxInstance.get('settings') ?? UserSettings();
  }

  Future<void> saveSettings(UserSettings s) async {
    await settingsBoxInstance.put('settings', s);
  }
}

import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String category;

  @HiveField(3)
  String label;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  bool isRecurring;

  @HiveField(6)
  bool isIncome;

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.label,
    required this.date,
    this.isRecurring = false,
    this.isIncome = false,
  });

  Transaction copyWith({
    String? id,
    double? amount,
    String? category,
    String? label,
    DateTime? date,
    bool? isRecurring,
    bool? isIncome,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      label: label ?? this.label,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}

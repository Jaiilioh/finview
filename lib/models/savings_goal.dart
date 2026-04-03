import 'package:hive/hive.dart';

part 'savings_goal.g.dart';

@HiveType(typeId: 2)
class SavingsGoal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double targetAmount;

  @HiveField(3)
  double currentAmount;

  @HiveField(4)
  DateTime targetDate;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  double get monthlyRequired {
    final now = DateTime.now();
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0) return 0;
    final monthsLeft =
        (targetDate.year - now.year) * 12 + (targetDate.month - now.month);
    if (monthsLeft <= 0) return remaining;
    return remaining / monthsLeft;
  }

  SavingsGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
    );
  }
}

import 'package:hive/hive.dart';

part 'budget_category.g.dart';

@HiveType(typeId: 1)
class BudgetCategory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String iconName;

  @HiveField(3)
  double budgetLimit;

  @HiveField(4)
  int colorValue;

  BudgetCategory({
    required this.id,
    required this.name,
    required this.iconName,
    required this.budgetLimit,
    this.colorValue = 0xFF003623,
  });

  BudgetCategory copyWith({
    String? id,
    String? name,
    String? iconName,
    double? budgetLimit,
    int? colorValue,
  }) {
    return BudgetCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}

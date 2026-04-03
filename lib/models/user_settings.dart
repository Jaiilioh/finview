import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 3)
class UserSettings extends HiveObject {
  @HiveField(0)
  double monthlyIncome;

  @HiveField(1)
  bool onboardingCompleted;

  @HiveField(2)
  int streakDays;

  @HiveField(3)
  DateTime? lastTransactionDate;

  UserSettings({
    this.monthlyIncome = 0.0,
    this.onboardingCompleted = false,
    this.streakDays = 0,
    this.lastTransactionDate,
  });
}

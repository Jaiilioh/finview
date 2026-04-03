import 'package:flutter/material.dart';

/// Maps category icon names to Material Icons.
class CategoryIcons {
  static const Map<String, IconData> icons = {
    'home': Icons.home_rounded,
    'restaurant': Icons.restaurant_rounded,
    'directions_car': Icons.directions_car_rounded,
    'subscriptions': Icons.subscriptions_rounded,
    'confirmation_number': Icons.confirmation_number_rounded,
    'savings': Icons.savings_rounded,
    'shopping_bag': Icons.shopping_bag_rounded,
    'more_horiz': Icons.more_horiz_rounded,
    'electric_bolt': Icons.electric_bolt_rounded,
    'payments': Icons.payments_rounded,
    'fitness_center': Icons.fitness_center_rounded,
    'school': Icons.school_rounded,
    'medical_services': Icons.medical_services_rounded,
    'pets': Icons.pets_rounded,
    'work': Icons.work_rounded,
    'flight': Icons.flight_rounded,
    'phone_android': Icons.phone_android_rounded,
  };

  static IconData getIcon(String name) {
    return icons[name] ?? Icons.category_rounded;
  }

  static List<String> get allNames => icons.keys.toList();
}

/// Default budget categories for onboarding.
class DefaultCategories {
  static List<Map<String, dynamic>> get categories => [
        {
          'name': 'Housing',
          'icon': 'home',
          'percentage': 0.30,
          'color': 0xFF003623,
        },
        {
          'name': 'Food',
          'icon': 'restaurant',
          'percentage': 0.15,
          'color': 0xFF004F35,
        },
        {
          'name': 'Transport',
          'icon': 'directions_car',
          'percentage': 0.10,
          'color': 0xFF006C4A,
        },
        {
          'name': 'Subscriptions',
          'icon': 'subscriptions',
          'percentage': 0.05,
          'color': 0xFF545F73,
        },
        {
          'name': 'Entertainment',
          'icon': 'confirmation_number',
          'percentage': 0.10,
          'color': 0xFF68DBA9,
        },
        {
          'name': 'Savings',
          'icon': 'savings',
          'percentage': 0.20,
          'color': 0xFF85F8C4,
        },
        {
          'name': 'Other',
          'icon': 'more_horiz',
          'percentage': 0.10,
          'color': 0xFFBFC9C3,
        },
      ];
}

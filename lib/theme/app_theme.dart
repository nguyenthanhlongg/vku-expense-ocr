import 'package:flutter/material.dart';

import '../models/expense.dart';

class AppTheme {
  static const Color vkuNavy = Color(0xFF2C4570);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: vkuNavy,
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: vkuNavy,
        brightness: Brightness.dark,
      ),
    );
  }
}

Color categoryColor(ExpenseCategory category) => switch (category) {
      ExpenseCategory.food => Colors.orange,
      ExpenseCategory.transport => Colors.blue,
      ExpenseCategory.shopping => Colors.purple,
      ExpenseCategory.utilities => Colors.teal,
      ExpenseCategory.other => Colors.blueGrey,
    };

IconData categoryIcon(ExpenseCategory category) => switch (category) {
      ExpenseCategory.food => Icons.restaurant,
      ExpenseCategory.transport => Icons.directions_bus,
      ExpenseCategory.shopping => Icons.shopping_bag,
      ExpenseCategory.utilities => Icons.bolt,
      ExpenseCategory.other => Icons.receipt_long,
    };

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense.dart';
import '../providers/expense_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/donut_chart.dart';
import '../widgets/weekly_bar_chart.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseListProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo chi tiêu')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Theo danh mục',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: CategoryDonutChart(expenses: expenses),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: ExpenseCategory.values.map((category) {
              return Chip(
                avatar: CircleAvatar(
                  backgroundColor: categoryColor(category),
                ),
                label: Text(category.label),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          Text(
            '7 ngày gần đây',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: WeeklyBarChart(expenses: expenses),
          ),
        ],
      ),
    );
  }
}

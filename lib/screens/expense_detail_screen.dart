import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/expense.dart';
import '../providers/expense_providers.dart';
import '../theme/app_theme.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final String expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expense = ref.watch(expenseByIdProvider(expenseId));
    if (expense == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết')),
        body: const Center(child: Text('Không tìm thấy khoản chi')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(expense.merchant),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await ref.read(expenseListProvider.notifier).remove(expense.id);
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (expense.receiptImagePath != null &&
              File(expense.receiptImagePath!).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(expense.receiptImagePath!),
                height: 240,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  categoryColor(expense.category).withValues(alpha: 0.18),
              child: Icon(
                categoryIcon(expense.category),
                color: categoryColor(expense.category),
              ),
            ),
            title: Text(expense.formattedAmount),
            subtitle: Text('${expense.category.label} • ${expense.formattedDate}'),
          ),
          if (expense.rawOcrText != null && expense.rawOcrText!.isNotEmpty) ...[
            const Divider(),
            Text('OCR gốc', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(expense.rawOcrText!),
          ],
        ],
      ),
    );
  }
}

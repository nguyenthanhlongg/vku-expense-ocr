import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/expense.dart';
import '../providers/expense_providers.dart';
import '../services/receipt_parser.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final ParsedReceipt parsed;

  const ReviewScreen({super.key, required this.parsed});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  late final TextEditingController _merchantController;
  late final TextEditingController _amountController;
  late DateTime _date;
  late ExpenseCategory _category;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _merchantController = TextEditingController(text: widget.parsed.merchant);
    final amount = widget.parsed.amount;
    _amountController = TextEditingController(
      text: amount == null ? '' : amount.toStringAsFixed(0),
    );
    _date = widget.parsed.date ?? DateTime.now();
    _category = widget.parsed.category;
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2018),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text.replaceAll(',', ''));
    final notifier = ref.read(expenseListProvider.notifier);

    String? storedPath = widget.parsed.imagePath;
    if (storedPath != null) {
      storedPath = await notifier.saveReceiptPhoto(storedPath);
    }

    final expense = Expense(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      merchant: _merchantController.text.trim(),
      amount: amount,
      date: _date,
      category: _category,
      receiptImagePath: storedPath,
      rawOcrText: widget.parsed.rawText,
    );
    await notifier.add(expense);
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận hóa đơn')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.parsed.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(widget.parsed.imagePath!),
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _merchantController,
              decoration: const InputDecoration(
                labelText: 'Cửa hàng',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nhập tên cửa hàng';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số tiền (đ)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final parsed = double.tryParse((value ?? '').replaceAll(',', ''));
                if (parsed == null || parsed <= 0) return 'Số tiền không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ngày'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ExpenseCategory>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Danh mục',
                border: OutlineInputBorder(),
              ),
              items: ExpenseCategory.values
                  .map(
                    (c) => DropdownMenuItem(value: c, child: Text(c.label)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            if (widget.parsed.rawText.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Văn bản OCR',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(widget.parsed.rawText),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('Lưu chi tiêu'),
            ),
          ],
        ),
      ),
    );
  }
}

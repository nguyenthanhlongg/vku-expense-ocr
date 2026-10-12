import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/expense_repository.dart';
import '../models/expense.dart';
import '../services/ocr_service.dart';
import '../services/receipt_parser.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

final ocrServiceProvider = Provider<OcrService>((ref) => OcrService());

final receiptParserProvider = Provider<ReceiptParser>((ref) => ReceiptParser());

final expenseListProvider =
    AsyncNotifierProvider<ExpenseListNotifier, List<Expense>>(
  ExpenseListNotifier.new,
);

class ExpenseListNotifier extends AsyncNotifier<List<Expense>> {
  ExpenseRepository get _repo => ref.read(expenseRepositoryProvider);

  @override
  Future<List<Expense>> build() => _repo.getAll();

  Future<void> add(Expense expense) async {
    await _repo.insert(expense);
    state = AsyncData(await _repo.getAll());
  }

  Future<void> updateExpense(Expense expense) async {
    await _repo.update(expense);
    state = AsyncData(await _repo.getAll());
  }

  Future<void> remove(String id) async {
    await _repo.delete(id);
    state = AsyncData(await _repo.getAll());
  }

  Future<String> saveReceiptPhoto(String sourcePath) {
    return _repo.persistReceiptImage(sourcePath);
  }
}

final expenseByIdProvider = Provider.family<Expense?, String>((ref, id) {
  final list = ref.watch(expenseListProvider).valueOrNull ?? const [];
  for (final item in list) {
    if (item.id == id) return item;
  }
  return null;
});

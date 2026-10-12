import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/expense.dart';
import 'app_database.dart';

class ExpenseRepository {
  Future<List<Expense>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('expenses', orderBy: 'date DESC');
    return rows.map(Expense.fromMap).toList();
  }

  Future<Expense?> getById(String id) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Expense.fromMap(rows.first);
  }

  Future<void> insert(Expense expense) async {
    final db = await AppDatabase.instance.database;
    await db.insert('expenses', expense.toMap());
  }

  Future<void> update(Expense expense) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<String> persistReceiptImage(String sourcePath) async {
    final docs = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory(p.join(docs.path, 'receipts'));
    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }
    final filename =
        'receipt_${DateTime.now().millisecondsSinceEpoch}${p.extension(sourcePath)}';
    final dest = p.join(receiptsDir.path, filename);
    await File(sourcePath).copy(dest);
    return dest;
  }
}

// lib/models/expense.dart
import 'package:intl/intl.dart';

/// Enum representing expense categories
enum ExpenseCategory { food, transport, shopping, utilities, other }

/// Extension to convert ExpenseCategory to/from string
extension ExpenseCategoryExtension on ExpenseCategory {
  String get label => switch (this) {
        ExpenseCategory.food => 'Ăn uống',
        ExpenseCategory.transport => 'Di chuyển',
        ExpenseCategory.shopping => 'Mua sắm',
        ExpenseCategory.utilities => 'Tiện ích',
        ExpenseCategory.other => 'Khác',
      };

  String get dbValue => name;

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExpenseCategory.other,
    );
  }
}

/// Main expense data model
class Expense {
  final String id;
  final String merchant;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;
  final String? receiptImagePath;
  final String? rawOcrText;

  const Expense({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.date,
    this.category = ExpenseCategory.other,
    this.receiptImagePath,
    this.rawOcrText,
  });

  /// Formatted date string
  String get formattedDate => DateFormat('dd/MM/yyyy').format(date);

  /// Formatted amount in Vietnamese Dong
  String get formattedAmount {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} đ';
  }

  /// Create from database map
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      merchant: map['merchant'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      category: ExpenseCategoryExtension.fromString(map['category'] as String),
      receiptImagePath: map['receipt_image_path'] as String?,
      rawOcrText: map['raw_ocr_text'] as String?,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'merchant': merchant,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'category': category.dbValue,
      'receipt_image_path': receiptImagePath,
      'raw_ocr_text': rawOcrText,
    };
  }

  /// Create a copy with modified fields
  Expense copyWith({
    String? id,
    String? merchant,
    double? amount,
    DateTime? date,
    ExpenseCategory? category,
    String? receiptImagePath,
    String? rawOcrText,
  }) {
    return Expense(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      rawOcrText: rawOcrText ?? this.rawOcrText,
    );
  }
}

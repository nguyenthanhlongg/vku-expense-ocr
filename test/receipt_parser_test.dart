import 'package:flutter_test/flutter_test.dart';
import 'package:vku_expense_ocr/models/expense.dart';
import 'package:vku_expense_ocr/services/receipt_parser.dart';

void main() {
  final parser = ReceiptParser();

  test('extracts merchant, VND total and date from a Vietnamese receipt', () {
    const raw = '''
Highlands Coffee Da Nang
Hoa don ban le
22/10/2026
Cafe sua da          45.000
Banh ngot            20.000
TONG CONG           65.000 d
''';
    final parsed = parser.parse(raw);
    expect(parsed.merchant, 'Highlands Coffee Da Nang');
    expect(parsed.amount, 65000);
    expect(parsed.date, DateTime(2026, 10, 22));
    expect(parsed.category, ExpenseCategory.food);
  });
}

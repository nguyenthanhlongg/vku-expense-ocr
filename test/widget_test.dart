import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:vku_expense_ocr/widgets/expense_summary_card.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('vi_VN');
  });

  testWidgets('ExpenseSummaryCard shows merchant, date and VND amount',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpenseSummaryCard(
            merchant: 'Highlands Coffee',
            amount: 65000,
            date: DateTime(2026, 10, 22),
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Highlands Coffee'), findsOneWidget);
    expect(find.text('22/10/2026'), findsOneWidget);
    expect(find.textContaining('65'), findsOneWidget);
    expect(find.textContaining('đ'), findsOneWidget);

    await tester.tap(find.byType(ExpenseSummaryCard));
    expect(tapped, isTrue);
  });
}

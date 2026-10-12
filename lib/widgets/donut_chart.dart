import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense.dart';
import '../theme/app_theme.dart';

class CategoryDonutChart extends StatelessWidget {
  final List<Expense> expenses;

  const CategoryDonutChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final totals = <ExpenseCategory, double>{};
    for (final item in expenses) {
      totals[item.category] = (totals[item.category] ?? 0) + item.amount;
    }
    final grandTotal = totals.values.fold<double>(0, (a, b) => a + b);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        return CustomPaint(
          painter: _DonutPainter(totals: totals, progress: t),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tổng',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${NumberFormat('#,###', 'vi_VN').format(grandTotal.round())} đ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  final Map<ExpenseCategory, double> totals;
  final double progress;

  _DonutPainter({required this.totals, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius - 8);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;

    final total = totals.values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) {
      stroke.color = Colors.grey.shade300;
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, stroke);
      return;
    }

    var start = -math.pi / 2;
    for (final category in ExpenseCategory.values) {
      final value = totals[category] ?? 0;
      if (value <= 0) continue;
      final sweep = (value / total) * 2 * math.pi * progress;
      stroke.color = categoryColor(category);
      canvas.drawArc(rect, start, sweep, false, stroke);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.totals != totals;
  }
}

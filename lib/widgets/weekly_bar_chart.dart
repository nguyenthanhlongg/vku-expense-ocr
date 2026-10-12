import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<Expense> expenses;

  const WeeklyBarChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final date = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 6 - i));
      return date;
    });
    final totals = <DateTime, double>{
      for (final day in days) day: 0,
    };
    for (final item in expenses) {
      final key = DateTime(item.date.year, item.date.month, item.date.day);
      if (totals.containsKey(key)) {
        totals[key] = totals[key]! + item.amount;
      }
    }
    final maxValue = totals.values.fold<double>(0, (a, b) => a > b ? a : b);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        return CustomPaint(
          painter: _BarPainter(
            days: days,
            totals: totals,
            maxValue: maxValue,
            progress: t,
            barColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
      },
    );
  }
}

class _BarPainter extends CustomPainter {
  final List<DateTime> days;
  final Map<DateTime, double> totals;
  final double maxValue;
  final double progress;
  final Color barColor;
  final Color labelColor;

  _BarPainter({
    required this.days,
    required this.totals,
    required this.maxValue,
    required this.progress,
    required this.barColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const topPad = 12.0;
    const bottomPad = 24.0;
    final chartHeight = size.height - topPad - bottomPad;
    final slot = size.width / days.length;
    final paint = Paint()..color = barColor;
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    for (var i = 0; i < days.length; i++) {
      final day = days[i];
      final value = totals[day] ?? 0;
      final ratio = maxValue <= 0 ? 0.0 : value / maxValue;
      final barHeight = chartHeight * ratio * progress;
      final barWidth = slot * 0.45;
      final x = slot * i + (slot - barWidth) / 2;
      final y = topPad + (chartHeight - barHeight);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight.clamp(0, chartHeight)),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, paint);

      textPainter.text = TextSpan(
        text: DateFormat('E', 'en').format(day).substring(0, 2),
        style: TextStyle(color: labelColor, fontSize: 11),
      );
      textPainter.layout(maxWidth: slot);
      textPainter.paint(
        canvas,
        Offset(slot * i + (slot - textPainter.width) / 2, size.height - 18),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.maxValue != maxValue;
  }
}

import '../models/expense.dart';

class ParsedReceipt {
  final String merchant;
  final double? amount;
  final DateTime? date;
  final ExpenseCategory category;
  final String rawText;
  final String? imagePath;

  const ParsedReceipt({
    required this.merchant,
    required this.rawText,
    this.amount,
    this.date,
    this.category = ExpenseCategory.other,
    this.imagePath,
  });

  ParsedReceipt copyWith({
    String? merchant,
    double? amount,
    DateTime? date,
    ExpenseCategory? category,
    String? rawText,
    String? imagePath,
  }) {
    return ParsedReceipt(
      merchant: merchant ?? this.merchant,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      rawText: rawText ?? this.rawText,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class ReceiptParser {
  static final _datePatterns = [
    RegExp(r'\b(\d{1,2})[\/\-.](\d{1,2})[\/\-.](\d{4})\b'),
    RegExp(r'\b(\d{4})[\/\-.](\d{1,2})[\/\-.](\d{1,2})\b'),
  ];

  static final _amountToken = RegExp(
    r'(?:(?:VND|VNĐ|đ|d)\s*)?(\d{1,3}(?:[.,]\d{3})+|\d+)(?:\s*(?:VND|VNĐ|đ|d))?',
    caseSensitive: false,
  );

  static final _totalKeywords = RegExp(
    r'(tong\s*cong|tổng\s*cộng|thanh\s*toan|thanh\s*toán|grand\s*total|'
    r'total|cong\s*tien|cộng\s*tiền|phai\s*tra|phải\s*trả|amount\s*due|'
    r'sum|tong\s*tien|tổng\s*tiền)',
    caseSensitive: false,
  );

  static final _skipMerchant = RegExp(
    r'(hoa\s*don|hóa\s*đơn|receipt|invoice|tax|vat|mst|wifi|www\.|http)',
    caseSensitive: false,
  );

  ParsedReceipt parse(String rawText, {String? imagePath}) {
    final lines = rawText
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final merchant = _extractMerchant(lines);
    final amount = _extractAmount(rawText, lines);
    final date = _extractDate(rawText);
    final category = inferCategory('$merchant\n$rawText');

    return ParsedReceipt(
      merchant: merchant,
      amount: amount,
      date: date,
      category: category,
      rawText: rawText,
      imagePath: imagePath,
    );
  }

  String _extractMerchant(List<String> lines) {
    for (final line in lines.take(6)) {
      if (line.length < 3) continue;
      if (_skipMerchant.hasMatch(line)) continue;
      if (_datePatterns.any((p) => p.hasMatch(line))) continue;
      if (_looksLikeAmountOnly(line)) continue;
      return line;
    }
    return 'Cửa hàng';
  }

  bool _looksLikeAmountOnly(String line) {
    final cleaned = line.replaceAll(RegExp(r'[\s]'), '');
    return RegExp(r'^[\d.,]+(đ|d|vnd)?$', caseSensitive: false).hasMatch(cleaned);
  }

  double? _extractAmount(String rawText, List<String> lines) {
    double? fromKeyword;
    for (final line in lines) {
      if (!_totalKeywords.hasMatch(line)) continue;
      final values = _amountsIn(line);
      if (values.isNotEmpty) {
        fromKeyword = values.reduce((a, b) => a > b ? a : b);
        break;
      }
    }
    if (fromKeyword != null) return fromKeyword;

    final all = _amountsIn(rawText).where((v) => v >= 1000).toList();
    if (all.isEmpty) return null;
    all.sort();
    return all.last;
  }

  List<double> _amountsIn(String text) {
    final results = <double>[];
    for (final match in _amountToken.allMatches(text)) {
      final raw = match.group(1);
      if (raw == null) continue;
      final value = _parseVnNumber(raw);
      if (value != null && value > 0) results.add(value);
    }
    return results;
  }

  double? _parseVnNumber(String raw) {
    final hasDot = raw.contains('.');
    final hasComma = raw.contains(',');
    String normalized = raw;
    if (hasDot && hasComma) {
      if (raw.lastIndexOf(',') > raw.lastIndexOf('.')) {
        normalized = raw.replaceAll('.', '').replaceAll(',', '.');
      } else {
        normalized = raw.replaceAll(',', '');
      }
    } else if (hasDot) {
      final parts = raw.split('.');
      if (parts.length > 1 && parts.last.length == 3) {
        normalized = raw.replaceAll('.', '');
      }
    } else if (hasComma) {
      final parts = raw.split(',');
      if (parts.length > 1 && parts.last.length == 3) {
        normalized = raw.replaceAll(',', '');
      } else {
        normalized = raw.replaceAll(',', '.');
      }
    }
    return double.tryParse(normalized);
  }

  DateTime? _extractDate(String rawText) {
    final dmy = _datePatterns[0].firstMatch(rawText);
    if (dmy != null) {
      final day = int.tryParse(dmy.group(1)!);
      final month = int.tryParse(dmy.group(2)!);
      final year = int.tryParse(dmy.group(3)!);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    final ymd = _datePatterns[1].firstMatch(rawText);
    if (ymd != null) {
      final year = int.tryParse(ymd.group(1)!);
      final month = int.tryParse(ymd.group(2)!);
      final day = int.tryParse(ymd.group(3)!);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  ExpenseCategory inferCategory(String text) {
    final t = _fold(text);
    if (RegExp(
      r'(cafe|coffee|highland|phở|pho|cơm|com|tra sua|trà sữa|kfc|'
      r'lotteria|pizza|bun|bún|an uong|ăn uống|nha hang|nhà hàng|food)',
    ).hasMatch(t)) {
      return ExpenseCategory.food;
    }
    if (RegExp(
      r'(grab|be xe|xăng|xang|petrol|taxi|bus|xe bus|di chuyen|di chuyển)',
    ).hasMatch(t)) {
      return ExpenseCategory.transport;
    }
    if (RegExp(
      r'(mart|co.?op|circle k|gs25|shopee|lazada|mua sam|mua sắm|sieuthi|siêu thị)',
    ).hasMatch(t)) {
      return ExpenseCategory.shopping;
    }
    if (RegExp(
      r'(điện|dien|nước|nuoc|internet|viettel|fpt|vnpt|tiện ích|tien ich)',
    ).hasMatch(t)) {
      return ExpenseCategory.utilities;
    }
    return ExpenseCategory.other;
  }

  String _fold(String input) {
    return input.toLowerCase();
  }
}

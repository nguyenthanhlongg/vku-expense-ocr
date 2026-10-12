import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/expense_providers.dart';
import '../services/receipt_parser.dart';
import '../widgets/expense_summary_card.dart';

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  Future<void> _pickAndScan(BuildContext context, WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file == null || !context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final ocr = ref.read(ocrServiceProvider);
      final parser = ref.read(receiptParserProvider);
      final raw = await ocr.recognizeText(file.path);
      final parsed = parser.parse(raw, imagePath: file.path);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      context.push('/review', extra: parsed);
    } catch (error) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không đọc được hóa đơn: $error')),
      );
    }
  }

  Future<void> _showScanSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp hóa đơn'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickAndScan(context, ref, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickAndScan(context, ref, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note),
                title: const Text('Nhập thủ công'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push(
                    '/review',
                    extra: ParsedReceipt(
                      merchant: '',
                      amount: null,
                      date: DateTime.now(),
                      rawText: '',
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expenseListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hóa đơn của tôi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Lỗi: $error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Chưa có hóa đơn nào được quét'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Dismissible(
                key: ValueKey(item.id),
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  ref.read(expenseListProvider.notifier).remove(item.id);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ExpenseSummaryCard.fromExpense(
                    expense: item,
                    onTap: () => context.push('/expense/${item.id}'),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showScanSheet(context, ref),
        icon: const Icon(Icons.camera_alt),
        label: const Text('Quét hóa đơn'),
      ),
    );
  }
}

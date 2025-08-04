import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../ model/transaction_model.dart';
import '../viewmodel/transaction_history_view_model.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');
final _filterTypeProvider = StateProvider<String>((ref) => 'All');

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionHistoryProvider);
    final searchQuery = ref.watch(_searchQueryProvider);
    final filterType = ref.watch(_filterTypeProvider);
    final viewModel = ref.read(transactionHistoryProvider.notifier);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredTx = transactions.where((tx) {
      final matchQuery = tx.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          tx.category.toLowerCase().contains(searchQuery.toLowerCase());
      final matchType = filterType == 'All' || tx.type.toLowerCase() == filterType.toLowerCase();
      return matchQuery && matchType;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: "Download PDF",
            onPressed: () async {
              await _generateAndPrintPDF(filteredTx);
            },
          )
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by title or category',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDark ? Colors.grey[900] : Colors.grey[200],
                  hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                onChanged: (value) =>
                ref.read(_searchQueryProvider.notifier).state = value,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DropdownButton<String>(
                    value: filterType,
                    dropdownColor: isDark ? Colors.grey[850] : Colors.white,
                    items: const ['All', 'Income', 'Expense'].map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(_filterTypeProvider.notifier).state = value;
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await viewModel.fetchTransactions();
                  },
                  child: filteredTx.isEmpty
                      ? ListView(
                    children: [
                      const SizedBox(height: 100),
                      Center(
                        child: Text(
                          "No transactions found.",
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredTx.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, index) {
                      final tx = filteredTx[index];
                      return Dismissible(
                        key: Key(tx.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          padding: const EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) async {
                          await viewModel.deleteTransaction(tx.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Transaction deleted")),
                          );
                        },
                        child: ListTile(
                          onLongPress: () => _showEditDialog(context, ref, tx),
                          leading: CircleAvatar(
                            backgroundColor:
                            tx.type == 'income' ? Colors.green : Colors.red,
                            child: Icon(
                              tx.type == 'income'
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(tx.title),
                          subtitle: Text(
                              "${tx.category} • ${DateFormat.yMMMd().format(tx.date)}"),
                          trailing: Text(
                            "PKR ${tx.amount.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: tx.type == 'income' ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, TransactionModel tx) {
    final titleController = TextEditingController(text: tx.title);
    final amountController = TextEditingController(text: tx.amount.toString());

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text("Edit Transaction"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Save"),
              onPressed: () async {
                final updatedTx = tx.copyWith(
                  title: titleController.text,
                  amount: double.tryParse(amountController.text) ?? tx.amount,
                );
                await ref
                    .read(transactionHistoryProvider.notifier)
                    .updateTransaction(updatedTx);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateAndPrintPDF(List<TransactionModel> transactions) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
            child: pw.Text('Transaction History',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            border: pw.TableBorder.all(),
            headers: ['Title', 'Type', 'Category', 'Amount', 'Date'],
            data: transactions.map((tx) {
              return [
                tx.title,
                tx.type.toUpperCase(),
                tx.category,
                'PKR ${tx.amount.toStringAsFixed(0)}',
                dateFormat.format(tx.date),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'transaction_history.pdf',
    );
  }
}

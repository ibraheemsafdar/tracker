import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/add_transaction_view_model.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends ConsumerWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(addTransactionProvider);
    final vm = ref.read(addTransactionProvider.notifier);

    final List<String> categories = [
      'Food',
      'Transport',
      'Shopping',
      'Salary',
      'Investment',
    ];

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Transaction"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  DropdownButtonFormField<String>(
                    value: model.type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: ['income', 'expense']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e.capitalize())))
                        .toList(),
                    onChanged: (value) => vm.setType(value!),
                  ),

                  const SizedBox(height: 12),


                  TextField(
                    decoration: const InputDecoration(labelText: 'Title'),
                    onChanged: vm.setTitle,
                  ),

                  const SizedBox(height: 12),


                  TextField(
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    onChanged: vm.setAmount,

                  ),

                  const SizedBox(height: 12),


                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: model.date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) vm.setDate(picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Date'),
                      child: Text(DateFormat.yMMMMd().format(model.date)),
                    ),
                  ),

                  const SizedBox(height: 12),


                  DropdownButtonFormField<String>(
                    value: model.category.isNotEmpty ? model.category : null,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: categories

                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => vm.setCategory(value ?? ''),
                  ),

                  const SizedBox(height: 12),


                  TextField(
                    decoration: const InputDecoration(labelText: 'Note (Optional)'),
                    onChanged: vm.setNote,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () async {
                      await vm.submitTransaction(context);


                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Add Transaction"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension StringX on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}

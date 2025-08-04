import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/SpendingGoalViewModel.dart';

class SpendingGoalsScreen extends ConsumerWidget {
  const SpendingGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(spendingGoalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Spending Goals")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final goal in goals)
            Card(
              child: ListTile(
                title: Text(
                  "${goal.category} — PKR ${goal.limitAmount.toStringAsFixed(0)}",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Confirm Deletion"),
                        content: const Text("Are you sure you want to delete this goal?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(spendingGoalProvider.notifier).removeGoal(goal.id);
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Add New Goal"),
            onPressed: () => _showAddDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final categoryCtrl = TextEditingController();
    final limitCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Goal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: categoryCtrl,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: limitCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Limit Amount (PKR)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final cat = categoryCtrl.text.trim();
              final val = double.tryParse(limitCtrl.text) ?? 0;
              if (cat.isEmpty || val <= 0) return;
              ref.read(spendingGoalProvider.notifier).addGoal(cat, val, context);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}

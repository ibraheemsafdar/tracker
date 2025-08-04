import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/category_model.dart';
import '../viewmodel/category_view_model.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);
    final viewModel = ref.read(categoryProvider.notifier);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listenManual(categoryProvider, (previous, next) {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchCategories(); // re-fetch based on current user
    });

    void _showCategoryDialog({CategoryModel? category}) {
      final TextEditingController nameController = TextEditingController(
        text: category?.name ?? '',
      );
      CategoryType selectedType = category?.type ?? CategoryType.expense;

      showDialog(
        context: context,
        builder: (_) {
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              backgroundColor: theme.cardColor,
              title: Text(
                category == null ? 'Add Category' : 'Edit Category',
                style: theme.textTheme.titleLarge,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Category Name'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<CategoryType>(
                    value: selectedType,
                    isExpanded: true,
                    items: CategoryType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedType = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    if (category == null) {
                      await viewModel.addCategory(name, selectedType);
                    } else {
                      await viewModel.editCategory(category.id, name, selectedType);
                    }

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(category == null ? "Add" : "Update"),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Category Management"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
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
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return ListTile(
                    title: Text(
                      cat.name,
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      cat.type.name.toUpperCase(),
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showCategoryDialog(category: cat),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => viewModel.removeCategory(cat.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

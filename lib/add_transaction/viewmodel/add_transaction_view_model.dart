import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ model/add_transaction_model.dart';
import '../../dashboard/viewmodel/dashboard_view_model.dart';


class AddTransactionViewModel extends StateNotifier<AddTransactionModel> {
  AddTransactionViewModel(this.ref) : super(AddTransactionModel.initial());


  final Ref ref;

  void setType(String value) => state = state.copyWith(type: value);

  void setTitle(String value) => state = state.copyWith(title: value);

  void setAmount(String value) {
    final amount = double.tryParse(value) ?? 0;
    state = state.copyWith(amount: amount);
  }

  void setDate(DateTime date) => state = state.copyWith(date: date);

  void setCategory(String value) => state = state.copyWith(category: value);

  void setNote(String value) => state = state.copyWith(note: value);

  Future<void> submitTransaction(BuildContext context) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final data = state.toMap(userId);

    try {
      await supabase.from('transactions').insert(data);

      await ref.read(dashboardViewModelProvider.notifier).fetchDashboardData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transaction added")),
      );
    } catch (e) {
      print("Error adding transaction: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add transaction")),
      );
    }
  }
}

final addTransactionProvider =
StateNotifierProvider<AddTransactionViewModel, AddTransactionModel>(
      (ref) => AddTransactionViewModel(ref),
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ model/transaction_model.dart';


class TransactionHistoryViewModel extends StateNotifier<List<TransactionModel>> {
  TransactionHistoryViewModel() : super([]);

  final supabase = Supabase.instance.client;

  Future<void> initialize() async {
    await fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      state = [];
      return;
    }

    final response = await supabase
        .from('transactions')
        .select()
        .eq('user_id', user.id)
        .order('date', ascending: false);

    final data = response as List<dynamic>;
    state = data.map((item) => TransactionModel.fromMap(item)).toList();
  }

  Future<void> deleteTransaction(String id) async {
    await supabase.from('transactions').delete().eq('id', id);
    state = state.where((tx) => tx.id != id).toList();
  }

  Future<void> updateTransaction(TransactionModel updatedTx) async {
    await supabase.from('transactions').update(updatedTx.toMap()).eq('id', updatedTx.id);

    final updatedList = [...state];
    final index = updatedList.indexWhere((tx) => tx.id == updatedTx.id);

    if (index != -1) {
      updatedList[index] = updatedTx;
      state = updatedList;
    }
  }

  Future<void> addTransaction(TransactionModel newTx) async {
    final response = await supabase.from('transactions').insert(newTx.toMap()).select().single();

    final createdTx = TransactionModel.fromMap(response);
    state = [createdTx, ...state];

    // ✅ Refresh transaction history
    await fetchTransactions();
  }

  void clear() {
    state = [];
  }
}

final transactionHistoryProvider = StateNotifierProvider<TransactionHistoryViewModel, List<TransactionModel>>(
      (ref) {
    final vm = TransactionHistoryViewModel();
    vm.fetchTransactions();
    return vm;
  },
);

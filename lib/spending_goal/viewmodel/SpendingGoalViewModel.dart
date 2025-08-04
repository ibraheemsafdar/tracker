import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/SpendingGoalModel.dart';


final spendingGoalProvider =
StateNotifierProvider<SpendingGoalViewModel, List<SpendingGoalModel>>(
      (ref) {
    final vm = SpendingGoalViewModel(ref);
    vm.fetchGoals();
    return vm;
  },
);

class SpendingGoalViewModel extends StateNotifier<List<SpendingGoalModel>> {
  final Ref ref;
  final supabase = Supabase.instance.client;

  SpendingGoalViewModel(this.ref) : super([]);

  Future<void> fetchGoals() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      state = [];
      return;
    }
    final now = DateTime.now();
    final response = await supabase
        .from('spending_goals')
        .select()
        .eq('user_id', user.id)
        .eq('month', now.month)
        .eq('year', now.year);

    final list = (response as List<dynamic>)
        .map((e) => SpendingGoalModel.fromMap(e))
        .toList();

    state = list;
  }

  Future<void> addGoal(
      String category, double limitAmount, BuildContext ctx) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    final now = DateTime.now();
    final model = SpendingGoalModel(
      id: '',
      category: category,
      limitAmount: limitAmount,
      month: now.month,
      year: now.year,
    );

    try {
      await supabase.from('spending_goals').insert(model.toMap(user.id));
      await fetchGoals();
      ScaffoldMessenger.of(ctx)
          .showSnackBar(const SnackBar(content: Text("Goal added.")));
    } catch (e) {
      ScaffoldMessenger.of(ctx)
          .showSnackBar(const SnackBar(content: Text("Failed to add goal")));
    }
  }

  Future<void> removeGoal(String id) async {
    await supabase.from('spending_goals').delete().eq('id', id);
    state = state.where((g) => g.id != id).toList();
  }
}

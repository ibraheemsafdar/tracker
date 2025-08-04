// dashboard_view_model.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/dashboard_model.dart';

class DashboardViewModel extends StateNotifier<DashboardModel> {
  DashboardViewModel() : super(DashboardModel.empty());

  Future<void> initialize() async {
    await fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final userId = user?.id;

    if (userId == null) return;

    try {
      // Fetch transactions
      final data = await supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false)
          .limit(10);

      final transactions = (data as List<dynamic>).map((item) {
        return Transaction(
          title: item['note'] ?? item['category'] ?? 'Unknown',
          amount: (item['amount'] as num).toDouble(),
          date: DateTime.parse(item['date']),
          type: item['type'] ?? 'expense',
        );
      }).toList();

      double totalIncome = 0;
      double totalExpense = 0;

      for (var tx in transactions) {
        if (tx.type == 'income') {
          totalIncome += tx.amount;
        } else {
          totalExpense += tx.amount;
        }
      }

      final balance = totalIncome - totalExpense;

      // Fetch profile info
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final userName = profile['name'] ?? 'User';
      final avatarUrl = profile['avatar_url'];

      state = DashboardModel(
        balance: balance,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        transactions: transactions,
        userName: userName,
        avatarUrl: avatarUrl,
      );
    } catch (e) {
      print("Error fetching dashboard: $e");
      state = DashboardModel.empty();
    }
  }

  Future<void> refreshDashboard() async {
    await fetchDashboardData();
  }
}

final dashboardViewModelProvider =
StateNotifierProvider<DashboardViewModel, DashboardModel>(
      (ref) => DashboardViewModel(),
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/analytics_model.dart';
import 'package:intl/intl.dart';
class AnalyticsViewModel extends StateNotifier<List<CategoryData>> {
  AnalyticsViewModel() : super([]) {
    loadCategoryData();
  }
  final supabase = Supabase.instance.client;
  Future<void> fetchAnalytics() async {
    await loadCategoryData();
  }
  Future<void> loadCategoryData() async {
    final response = await supabase
        .from('transactions')
        .select('category, amount')
        .eq('type', 'expense');
    final data = response as List<dynamic>;
    final Map<String, double> categoryMap = {};
    for (final item in data) {
      final category = item['category'] as String? ?? 'Unknown';
      final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
      categoryMap.update(category, (value) => value + amount, ifAbsent: () => amount);
    }
    state = categoryMap.entries
        .map((e) => CategoryData(e.key, e.value))
        .toList();
  }
  Future<List<MonthlyData>> getMonthlyData() async {
    final response = await supabase
        .from('transactions')
        .select('amount, type, date');
    final data = response as List<dynamic>;
    final Map<String, double> incomeMap = {};
    final Map<String, double> expenseMap = {};
    for (final item in data) {
      final type = item['type'] as String?;
      final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
      final dateStr = item['date'] as String?;
      if (dateStr == null) continue;
      final month = DateFormat('MMM').format(DateTime.parse(dateStr));
      if (type == 'income') {
        incomeMap.update(month, (value) => value + amount, ifAbsent: () => amount);
      } else if (type == 'expense') {
        expenseMap.update(month, (value) => value + amount, ifAbsent: () => amount);
      }
    }
    final allMonths = {...incomeMap.keys, ...expenseMap.keys}.toList()..sort();
    return allMonths.map((month) {
      return MonthlyData(
        month,
        incomeMap[month] ?? 0,
        expenseMap[month] ?? 0,
      );
    }).toList();
  }
}
final analyticsProvider = StateNotifierProvider<AnalyticsViewModel, List<CategoryData>>(
      (ref) => AnalyticsViewModel(),
);

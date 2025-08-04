import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodel/analytics_view_model.dart';
import '../model/analytics_model.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsProvider.notifier).fetchAnalytics();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(analyticsProvider.notifier).fetchAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    final categoryData = ref.watch(analyticsProvider);
    final viewModel = ref.read(analyticsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Pie Chart Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Spending by Category",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    categoryData.isEmpty
                        ? const Center(child: Text("No category data"))
                        : SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                          sections: categoryData.map((data) {
                            final index = categoryData.indexOf(data);
                            final color = Colors.primaries[index % Colors.primaries.length];
                            final showTitle = data.amount > 5000;

                            return PieChartSectionData(
                              color: color,
                              value: data.amount,
                              title: showTitle
                                  ? "${data.category}\nPKR ${data.amount.toStringAsFixed(0)}"
                                  : '',
                              radius: 80,
                              titleStyle: const TextStyle(fontSize: 11, color: Colors.white),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bar Chart Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Monthly Income vs Expense",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder<List<MonthlyData>>(
                      future: viewModel.getMonthlyData(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final monthlyData = snapshot.data!;
                        final maxY = ([
                          ...monthlyData.map((e) => e.income),
                          ...monthlyData.map((e) => e.expense)
                        ].reduce((a, b) => a > b ? a : b) * 1.2)
                            .ceilToDouble();

                        return SizedBox(
                          height: 300,
                          child: BarChart(
                            BarChartData(
                              maxY: maxY,
                              barGroups: monthlyData.map((data) {
                                final index = monthlyData.indexOf(data);
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: data.income,
                                      color: Colors.green,
                                      width: 10,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    BarChartRodData(
                                      toY: data.expense,
                                      color: Colors.red,
                                      width: 10,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                );
                              }).toList(),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, _) {
                                      final index = value.toInt();
                                      if (index < 0 || index >= monthlyData.length) {
                                        return const SizedBox.shrink();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          monthlyData[index].month,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: (maxY / 4).toDouble(),
                                    reservedSize: 48,
                                    getTitlesWidget: (value, _) => Text(
                                      "PKR\n${value.toInt()}",
                                      style: const TextStyle(fontSize: 10),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: FlGridData(show: true),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

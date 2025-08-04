// dashboard_model.dart

class Transaction {
  final String title;
  final double amount;
  final DateTime date;
  final String type;

  Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });
}

class DashboardModel {
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final List<Transaction> transactions;
  final String userName;
  final String? avatarUrl;

  DashboardModel({
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    required this.transactions,
    required this.userName,
    required this.avatarUrl,
  });

  factory DashboardModel.empty() {
    return DashboardModel(
      balance: 0.0,
      totalIncome: 0.0,
      totalExpense: 0.0,
      transactions: [],
      userName: '',
      avatarUrl: null,
    );
  }
}

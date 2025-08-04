

class AddTransactionModel {
  final String type;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String note;

  AddTransactionModel({
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.note,
  });

  AddTransactionModel copyWith({
    String? type,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    String? note,
  }) {
    return AddTransactionModel(
      type: type ?? this.type,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }

  factory AddTransactionModel.initial() => AddTransactionModel(
    type: 'expense',
    title: '',
    amount: 0,
    date: DateTime.now(),
    category: '',
    note: '',
  );


  Map<String, dynamic> toMap(String userId) {
    return {
      'user_id': userId,
      'amount': amount,
      'type': type,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
    };
  }
}

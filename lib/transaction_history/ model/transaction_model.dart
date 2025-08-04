class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type;
  final String category;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      title: map['note'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      type: map['type'] ?? '',
      category: map['category'] ?? '',
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? type,
    String? category,
    DateTime? date,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }
}

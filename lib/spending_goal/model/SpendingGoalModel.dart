class SpendingGoalModel {
  final String id;
  final String category;
  final double limitAmount;
  final int month;
  final int year;

  SpendingGoalModel({
    required this.id,
    required this.category,
    required this.limitAmount,
    required this.month,
    required this.year,
  });

  factory SpendingGoalModel.fromMap(Map<String, dynamic> map) =>
      SpendingGoalModel(
        id: map['id'] as String,
        category: map['category'] as String,
        limitAmount: (map['limit_amount'] as num).toDouble(),
        month: map['month'] as int,
        year: map['year'] as int,
      );

  Map<String, dynamic> toMap(String userId) => {
    'user_id': userId,
    'category': category,
    'limit_amount': limitAmount,
    'month': month,
    'year': year,
  };
}

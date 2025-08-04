

enum CategoryType { income, expense }

class CategoryModel {
  final int id;
  final String name;
  final CategoryType type;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      type: map['type'] == 'income' ? CategoryType.income : CategoryType.expense,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.name,
    };
  }
}

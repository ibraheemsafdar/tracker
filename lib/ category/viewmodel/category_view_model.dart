import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/category_model.dart';

class CategoryViewModel extends StateNotifier<List<CategoryModel>> {
  CategoryViewModel() : super([]) {
    fetchCategories();
  }

  final _client = Supabase.instance.client;

  Future<void> fetchCategories() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final response = await _client
        .from('categories')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    state = (response as List)
        .map((e) => CategoryModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addCategory(String name, CategoryType type) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final response = await _client
        .from('categories')
        .insert({
      'name': name,
      'type': type.name,
      'user_id': userId,
    })
        .select();

    if (response != null && response.isNotEmpty) {
      final newCategory = CategoryModel.fromMap(response.first);
      state = [newCategory, ...state];
    }
  }

  Future<void> removeCategory(int id) async {
    await _client.from('categories').delete().eq('id', id);
    state = state.where((cat) => cat.id != id).toList();
  }

  Future<void> editCategory(int id, String newName, CategoryType newType) async {
    await _client.from('categories').update({
      'name': newName,
      'type': newType.name,
    }).eq('id', id);

    state = state.map((cat) {
      if (cat.id == id) {
        return CategoryModel(id: id, name: newName, type: newType);
      }
      return cat;
    }).toList();
  }
}

final categoryProvider = StateNotifierProvider<CategoryViewModel, List<CategoryModel>>(
      (ref) => CategoryViewModel(),
);

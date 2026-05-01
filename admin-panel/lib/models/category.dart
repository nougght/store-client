import 'package:flutter/foundation.dart';
import 'package:admin_panel/api_client.dart';

class Category {
  Category({this.id = "", this.name = "category_name", this.description = ""});

  String id;
  String name;
  String description;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? "",
      name: json['name'] ?? "category_name",
      description: json['description'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}

class CategoryModel extends ChangeNotifier {
  final ApiService apiService;
  CategoryModel(this.apiService) {
    loadCategories();
  }
  bool isLoading = true;
  List<Category> _categories = [];

  List<Category> get categories => List.unmodifiable(_categories);

  Category? getById(String id) => _categories.firstWhere((c) => c.id == id, orElse: null);

  Future<void> loadCategories() async {
    _categories = await apiService.fetchCategories();
    isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    _categories.add(await apiService.createCategory(category));
    notifyListeners();
  }

  Future<void> updateCategory(Category updatedCategory) async {
    int index = _categories.indexWhere((c) => c.id == updatedCategory.id);
    if (index != -1) {
      _categories[index] = await apiService.updateCategory(updatedCategory.id, updatedCategory);
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    await apiService.deleteCategory(id);
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}

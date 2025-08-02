import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:mobile_store/classes.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store/classes.dart' as classes;
import 'package:mobile_store/services/api_service.dart';

// class CartItem

class CatalogModel with ChangeNotifier {
  final ApiService api;
  bool productsLoaded = false;
  bool categoriesLoaded = false;
  String selectedCategoryId = '';
  String searchQuery = '';
  List<Product> _products = [];
  List<classes.Category> categories = [];

  CatalogModel(this.api);

  List<Product> get filteredProducts {
    var filtered = _products.where((product) {
      final matchesCategory = selectedCategoryId.isEmpty ||
          product.categoryId == selectedCategoryId;
      final matchesSearch = searchQuery.isEmpty ||
          product.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
    return filtered;
  }

  void setSelectedCategory(String categoryId) {
    selectedCategoryId = categoryId;
    // productsLoaded = false; // Сброс флага загрузки продуктов
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    // productsLoaded = false; // Сброс флага загрузки продуктов
    notifyListeners();
  }

  Future<bool> fetchCategories() async {
    try {
      final response = await api.fetchCategories();
      categories = response;
      categoriesLoaded = true;
      notifyListeners();
      debugPrint('Категории загружены: ${categories.length}');
      return true;
    } catch (e) {
      debugPrint('Ошибка загрузки категорий: $e');
      return false;
    }
  }

  Future<bool> fetchProducts() async {
    try {
      final response = await api.fetchProducts();
      _products = response;
      productsLoaded = true;
      notifyListeners();
      debugPrint('Продукты загружены: ${_products.length}');
      return true;
    } catch (e) {
      debugPrint('Ошибка загрузки продуктов: $e');
      return false;
    }
  }


  // Получаем список выбранных товаров (опционально)
  // List<CartItem> get selectedItems {
  //   return cartItems.where((item) => item.isChecked).toList();
  // }



}

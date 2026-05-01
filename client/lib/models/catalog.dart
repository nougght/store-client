import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:mobile_store/classes.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store/classes.dart' as classes;
import 'package:mobile_store/services/api_service.dart';
import 'package:mobile_store/models/product.dart';

// class CartItem

class CatalogModel with ChangeNotifier {
  final ApiService api;
  final ProductProvider productProvider;
  bool productsLoaded = false;
  bool categoriesLoaded = false;
  String? selectedCategoryId;
  String searchQuery = '';
  // List<Product> _products = [];
  List<classes.Category> categories = [];
  int? selectedSort = 0;
  int page = 1;
  int limit = 20;

  void setSort(int? value, BuildContext context) {
    page = 1;

    productsLoaded = false; // Сброс флага загрузки продуктов

    notifyListeners();
    filteredProducts(context, append: false);
    notifyListeners();
  }

  CatalogModel(this.api, this.productProvider);

  String sortToString(int? sort) {
    switch (sort) {
      case 0:
        return "price_asc";
      case 1:
        return "price_desc";
      case 2:
        return "created_asc";
      default:
        return "created_desc";
    }
  }

  Future<void> filteredProducts(BuildContext context, {append = false}) async {
    if (append) page++;
    if (selectedCategoryId == null && searchQuery.isEmpty) {
      // Если нет выбранной категории и нет поискового запроса, просто загружаем все товары
      await productProvider.fetchList(
        key: "catalog",
        filters: {"sort": sortToString(selectedSort)},
        page: page,
        limit: limit,
        append: append,
        context: context,
      );
      productsLoaded = true;
      notifyListeners();
      return;
    } else {
      // Если есть категория или поисковый запрос, фильтруем товары
      Map<String, dynamic> filters = {};
      if (selectedCategoryId != null && selectedCategoryId != null) {
        filters['category'] = selectedCategoryId;
        filters['sort'] = sortToString(selectedSort);
        filters['search'] = searchQuery;
      } else if (searchQuery.isNotEmpty) {
        filters['search'] = searchQuery;
        filters['sort'] = sortToString(selectedSort);
      }
      await productProvider.fetchList(
        key: "catalog",
        filters: filters,
        page: page,
        limit: limit,
        append: append,
        context: context,
      );
      productsLoaded = true;
      notifyListeners();
      return;
    }
    // var filtered = _products.where((product) {
    //   // final matchesCategory = selectedCategoryId.isEmpty ||
    //   //     product.categoryId == selectedCategoryId;
    //   final matchesSearch = searchQuery.isEmpty ||
    //       product.name.toLowerCase().contains(searchQuery.toLowerCase());
    //   return matchesSearch;
    // }).toList();
    // filtered.sort((a, b) {
    //   switch(selectedSort) {
    //     case 0: return a.price.compareTo(b.price);
    //     case 1: return b.price.compareTo(a.price);
    //     case 2: return a.creationDate.compareTo(b.creationDate);
    //     default: return a.creationDate.compareTo(b.creationDate);
    //   }
    // });
    // return filtered;
  }

  void setSelectedCategory(String? categoryId, BuildContext context) async {
    selectedCategoryId = categoryId;
    page = 1;

    productsLoaded = false; // Сброс флага загрузки продуктов

    notifyListeners();
    filteredProducts(context, append: false,);
    notifyListeners();
  }

  void setSearchQuery(String query, BuildContext context) {
    searchQuery = query;
    page = 1;
    productsLoaded = false; // Сброс флага загрузки продуктов
    notifyListeners();
    filteredProducts(context ,append: false);
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

  // Future<bool> fetchProducts() async {
  //   try {
  //     final response = await api.fetchProducts();
  //     _products = response;
  //     productsLoaded = true;
  //     notifyListeners();
  //     debugPrint('Продукты загружены: ${_products.length}');
  //     return true;
  //   } catch (e) {
  //     debugPrint('Ошибка загрузки продуктов: $e');
  //     return false;
  //   }
  // }

  // Получаем список выбранных товаров (опционально)
  // List<CartItem> get selectedItems {
  //   return cartItems.where((item) => item.isChecked).toList();
  // }
}

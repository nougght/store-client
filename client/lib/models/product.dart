import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:mobile_store/services/api_service.dart';
import 'package:mobile_store/classes.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService apiService;

  // Кэш всех товаров по id
  final Map<String, Product> _productCache = {};

  // Разные списки (например, для главной страницы, каталога и т.д.)
  Map<String, List<String>> _lists = {};

  ProductProvider({required this.apiService});

  /// Получить список товаров по ключу (например "home", "catalog:shoes")
  List<Product> getList(String key) {
    final ids = _lists[key] ?? [];
    return ids.map((id) => _productCache[id]!).toList();
  }

  /// Ленивое получение списка (с фильтрами/сортировкой)
  Future<void> fetchList({
    required String key,
    required Map<String, dynamic> filters,
    int page = 1,
    int limit = 20,
    bool append = false,
    required BuildContext context,
  }) async {
    final products = await apiService.getProductsPage(filters: filters, page: page, limit: limit);

    // Обновляем кэш
    List<Future<List<String>>> imageFutures = [];
    for (var p in products) {
      _productCache[p.id] = p;
      imageFutures.add(_productCache[p.id]?.getImages(context) ?? Future.value([]));
    }

    await Future.wait(imageFutures);
    
    // Обновляем список
    if (append && _lists.containsKey(key)) {
      _lists[key] = [..._lists[key]!, ...products.map((p) => p.id)];
    } else {
      _lists[key] = products.map((p) => p.id).toList();
    }
    _lists = Map.from(_lists);
    notifyListeners();
  }

  /// Найти товар в кэше
  Product? findInCache(String id) => _productCache[id];

  Future<void> fetchListByIds(String key, List<String> ids, BuildContext context) async {
    List<String> idsToFetch = [];
    for (var id in ids) {
      if (_productCache.containsKey(id)) continue; // Если уже есть в кэше, пропускаем
      idsToFetch.add(id);
    }
    String query = idsToFetch.join(',');
    if (query.isNotEmpty) {
      final products = await apiService.fetchProductsByIds(query);
      List<Future<List<String>>> imageFutures = [];
      for (var p in products) {
        _productCache[p.id] = p;
        imageFutures.add(_productCache[p.id]?.getImages(context) ?? Future.value([]));
      }

      await Future.wait(imageFutures);
    }
    _lists[key] = ids.map((e) {
      return findInCache(e)?.id ?? e;
    }).toList();

    _lists = Map.from(_lists);
    notifyListeners();
  }

  /// Получить товар по ID (гибридный вариант)
  Future<Product?> getProductById(String id, BuildContext context, {bool forceRefresh = false}) async {
    if (!forceRefresh && _productCache.containsKey(id)) {
      // Обновляем в фоне, но возвращаем сразу
      _refreshProduct(id);
      if (_productCache[id]!.hasImage == true && _productCache[id]!.images.isEmpty) {
        await _productCache[id]!.getImages(context);
      }
      return _productCache[id]!;
    }
    try {
      final resp = await apiService.fetchProductsByIds(id);
      if (resp.isNotEmpty) {
        _productCache[id] = resp[0];
        if (_productCache[id]!.hasImage == true && _productCache[id]!.images.isEmpty) {
          await _productCache[id]!.getImages(context);
        }
        notifyListeners();
        return resp[0];
      } else {
        throw Exception('Product not found');
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }


  Future<List<Product?>> getProductsByIds(List<String> ids, BuildContext context) async {
    List<Future<Product?>> productFutures = [];

    for (String id in ids) {
      productFutures.add(getProductById(id, context));
    }

    var result = await Future.wait(productFutures);

    return result;
  }

  /// Обновление товара в фоне
  Future<void> _refreshProduct(String id) async {
    try {
      final resp = await apiService.fetchProductsByIds(id);
      if (resp.isEmpty) {
        debugPrint('Product not found');
      } else {
        resp[0].hasImage = _productCache[id]?.hasImage ?? true;
        resp[0].images = _productCache[id]?.images ?? [];
        _productCache[id] = resp[0];

        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

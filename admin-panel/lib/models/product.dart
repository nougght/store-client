import 'package:flutter/foundation.dart';
import 'package:admin_panel/api_client.dart';

class Product {
  Product({
    this.id = "",
    this.name = "product_name",
    this.description = "",
    this.price = 0.0,
    this.categoryId = "",
    this.quantity = 0.0,
    this.unit = "шт",
    // List<String>? images,
    this.stock = 0,
    DateTime? creationDate,
  }) :  creationDate = creationDate ?? DateTime.now();

  String id;
  String name;
  String description;
  double price;
  double quantity;
  String unit;
  String categoryId;
  // List<String> images;
  int stock;
  DateTime creationDate;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? "",
      name: json['name'] ?? "category_name",
      description: json['description'] ?? "",
      price: json['price'] ?? 0.0,
      categoryId: json['category_id'] ?? "",
      quantity: json['quantity'] ?? 1.0,
      unit: json['unit'] ?? "шт",

      // images: json['images'] ?? [],
      stock: json['stock'] ?? 1,
      creationDate: DateTime.parse(json['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'category_id': categoryId,
      // 'images': images,
      'stock': stock,
      'created_at': creationDate.toUtc().toIso8601String()
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    List<String>? images,
    double? quantity,
    String? unit,
    int? stock,
    // bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      // images: images ?? this.images,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      // isActive: isActive ?? this.isActive,
    );
  }
}

class ProductProvider extends ChangeNotifier {
  final ApiService apiService;

  ProductProvider({required this.apiService}) {
    fetchProducts();
  }

  List<Product> products = [];
  Product? _selectedProduct;
  bool _isLoading = true;

  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;

  List<Product> productsByCategoryId(String categoryId)
  {
    return products.where((product) => product.categoryId == categoryId).toList();
  }

  /// Загрузка всех товаров
  Future<void> fetchProducts() async {
    notifyListeners();
    try {
      products = await apiService.fetchProducts();
    } catch (e) {
      debugPrint('Ошибка загрузки товаров: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Выбор товара для редактирования
  void selectProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  /// Добавление нового товара
  Future<void> addProduct(Product product) async {
    try {
      final newProduct = await apiService.createProduct(product);
      products.add(newProduct);
      products = products;
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка добавления товара: $e');
    }
  }

  /// Обновление существующего товара
  Future<void> updateProduct(Product product) async {
    try {
      final updatedProduct = await apiService.updateProduct(product.id, product);
      final index = products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        products[index] = updatedProduct;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Ошибка обновления товара: $e');
    }
  }

  /// Удаление товара
  Future<void> deleteProduct(String uuid) async {
    try {
      await apiService.deleteProduct(uuid);
      products.removeWhere((p) => p.id == uuid);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка удаления товара: $e');
    }
  }
}

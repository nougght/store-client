import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_store/classes.dart';
import 'package:mobile_store/models/product.dart';
import 'package:mobile_store/services/api_service.dart';

// class CartItem

class CartModel with ChangeNotifier {
  final ApiService api;
  final ProductProvider productProvider;
  bool cartLoaded = false;
  List<Product> _products = [];
  String? cartId;
  List<CartItem> cartItems = [];
  bool isAllChecked = false;

  CartModel(this.api, this.productProvider);

  int get totalQuantity {
    return cartItems.fold(0, (sum, item) {
      return sum + item.quantity;
    });
  }

  List<Product> get products {
    _products = productProvider.getList("cart");
    return _products;
  }

  double get totalPrice {
    return cartItems.fold(0.0, (sum, item) {
      final product = products.firstWhere(
        (prod) => prod.id == item.productId,
        orElse: () => Product(id: '', name: '', description: '', price: 0.0, stock: 0),
      );
      return sum + (product.price * item.quantity);
    });
  }

  double get deliveryPrice {
    return totalQuantity * 10;
  }

  CartItem getCartItemById(String cartItemId) {
    return cartItems.firstWhere(
      (item) => item.id == cartItemId,
      orElse: () => CartItem(id: '', productId: '', quantity: 0, isChecked: false),
    );
  }

  Future<void> setCartIdByUserId(String? userId, BuildContext context) async {
    if (userId != null) {
      try {
        cartId = await api.GetCartIdByUserId(userId);
        await fetchCartItems(context);
        await productProvider.fetchListByIds("cart", getCartItemsIds(), context);
        cartLoaded = true;
      } catch (e) {
        debugPrint('Ошибка загрузки корзины: $e');
      }

      notifyListeners();
      // cartLoaded = true;
    }
  }

  bool isProductInCart(String productId) {
    return cartItems.any((item) => item.productId == productId);
  }

  int getProductQuantity(String productId) {
    final item = cartItems.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItem(quantity: 0),
    );
    return item.quantity;
  }

  Future<void> addToCart(Product product, BuildContext context) async {
    CartItem ItemToAdd = CartItem(
      cart_id: cartId ?? "",
      productId: product.id,
      quantity: 1,
      isChecked: false,
    );

    try {
      final response = await api.addToCart(ItemToAdd);
      debugPrint('Добавлено в корзину: $response');
      ItemToAdd.id = response; // Получаем ID добавленного товара
      cartItems.add(ItemToAdd);
      await productProvider.fetchListByIds("cart", getCartItemsIds(), context);
      products;
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка добавления в корзину: $e');
    }
  }

  Future<void> removeSelected(BuildContext context) async {
    var items = selectedItems;
    try {
      final response = await api.deleteSelected(items);
      debugPrint('Удалено из корзины: $response');
      for (var item in items) {
        cartItems.remove(item);
        await productProvider.fetchListByIds("cart", getCartItemsIds(), context);
        products;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка удаления из корзины: $e');
    }
  }

  Future<void> toggleSelectAll(bool? value) async {
    isAllChecked = value ?? false;
    for (var item in cartItems) {
      item.isChecked = isAllChecked;
    }
    cartItems = List.from(cartItems); // Обновляем список для уведомления слушателей
    notifyListeners();
  }

  // Получаем список выбранных товаров (опционально)
  List<CartItem> get selectedItems {
    return cartItems.where((item) => item.isChecked).toList();
  }

  Future<bool> deleteFromCart(Product product, BuildContext context) async {
    var itemToDelete = cartItems.firstWhere((item) {
      return item.productId == product.id;
    }, orElse: () => CartItem());

    try {
      if (itemToDelete.id.isEmpty) {
        debugPrint('Товар не найден в корзине: ${product.name}');
        return true;
      }
      final response = await api.deleteFromCart(itemToDelete.id);
      cartItems.remove(itemToDelete);
      await productProvider.fetchListByIds("cart", getCartItemsIds(), context);
      products;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка удаления из корзины: $e');
      return false;
    }
  }

  Future<bool> updateCartItemQuantity(Product product, int newQuantity) async {
    var ItemToUpdate = cartItems.firstWhere((item) {
      return item.productId == product.id;
    });

    try {
      final response = await api.updateCartItem({"id": ItemToUpdate.id, "quantity": newQuantity});
      ItemToUpdate.quantity = newQuantity;
      cartItems = List.from(cartItems); // Обновляем список для уведомления слушателей
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка обновления корзины: $e');
      return false;
    }
  }

  Future<void> fetchCartItems(BuildContext context) async {
    try {
      final response = await api.fetchCartItems(id: cartId!);
      cartItems = response;
      await productProvider.fetchListByIds("cart", getCartItemsIds(), context);
      cartLoaded = true;
    } catch (e) {
      debugPrint('Ошибка загрузки корзины: $e');
    }
  }

  List<String> getCartItemsIds () {
    return cartItems.map((item) => item.productId).toList();
  }
  // Future<void> fetchProducts() async {
  //   if (cartItems.isEmpty) {
  //     productsLoaded = true;
  //     debugPrint('Корзина пуста, загрузка продуктов не требуется.');
  //   } else {
  //     String query = "";
  //     for (var item in cartItems) {
  //       query += item.productId + ",";
  //     }
  //     query = query.substring(0, query.length - 1);
  //     debugPrint(query);
  //     try {
  //       final response = await api.fetchProductsByIds(query);
  //       products = response;
  //       productsLoaded = true;
  //     } catch (e) {
  //       debugPrint('Ошибка загрузки продуктов: $e');
  //     }
  //   }
  //   notifyListeners();
  // }
}

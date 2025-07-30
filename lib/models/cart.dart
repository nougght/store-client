import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_store/classes.dart';
import 'package:mobile_store/services/api_service.dart';

// class CartItem

class CartModel with ChangeNotifier {
  final ApiService api;
  String? cartId;
  List<dynamic> cartItems = [];
  List<dynamic> products = [];

  CartModel(this.api);

  Future<void> getCartId(String? userId) async {
    // временно
    cartId = "7d74c974-29ae-4307-95fc-4c7dff3172a8";
  }

  Future<void> addToCart(Product product) async {
    getCartId("");
    var ItemToAdd = cartItems.firstWhere((item) {
      return item["product_id"] == product.id;
    }, orElse: () => null);
    if (ItemToAdd != null) {
      ItemToAdd["quantity"] += 1;
    } else {
      ItemToAdd = {"cart_id": cartId, 'product_id': product.id, 'quantity': 1};
      cartItems.add(ItemToAdd);
      products.add(product.toJson());
    }
    
    notifyListeners();

    try {
      final response = await api.addToCart(ItemToAdd);
    } catch (e) {
      debugPrint('Ошибка обновления корзины: $e');
    }
  }


  Future<void> fetchCartItems() async {
    final url = Uri.parse(
      'https://26aef7d5e7a1.ngrok-free.app/cart/085ed1df-58f5-43fc-8f67-1d9de231d9a8',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var items = json.decode(response.body);
        if (items != null) {
          cartItems = items;
          await fetchProducts();
        }
        // print(data);
      } else {
        print('Ошибка: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка: $e');
    }
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    String query = "";
    for (var item in cartItems) {
      query += item["product_id"] + ",";
    }
    query = query.substring(0, query.length - 1);
    debugPrint(query);
    final url = Uri.parse('https://26aef7d5e7a1.ngrok-free.app/products?ids=$query');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        products = json.decode(response.body);
        // print(data);
      } else {
        print('Ошибка: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка: $e');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_store/classes.dart';

class ApiService {
  final String _emUrl = "http://10.0.2.2:8080";
  final String _localUrl = "http://127.0.0.1";

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse("$_emUrl/products"));
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((item) => Product.fromJson(item))
          .toList();
    } else {
      throw Exception('Ошибка загрузки продуктов: ${response.statusCode}');
    }
  }



  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse("$_emUrl/categories"));

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((item) => Category.fromJson(item))
            .toList();
        // print(data);
      } else {
        throw Exception('Ошибка загрузки категорий: ${response.statusCode}');
      }
    }


  Future<List<CartItem>> fetchCartItems({
    String id = "7d74c974-29ae-4307-95fc-4c7dff3172a8",
  }) async {
    final response = await http.get(Uri.parse("$_emUrl/cart/$id"));

    if (response.statusCode == 200) {
      var decoded = json.decode(response.body);
      return decoded is List
          ? (decoded as List).map((item) => CartItem.fromJson(item)).toList()
          : [];
    } else {
      throw Exception(
        'Ошибка загрузки корзины: ${response.statusCode}${response.body}',
      );
    }
  }

  Future<List<Product>> fetchProductsByIds(String query) async {
    final response = await http.get(Uri.parse("$_emUrl/products?ids=$query"));
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((item) => Product.fromJson(item))
          .toList();
    } else {
      throw Exception(
        'Ошибка загрузки продуктов в корзине: ${response.statusCode}',
      );
    }
  }

  Future<String> addToCart(CartItem item) async {
    final bd = json.encode(item);
    final url = Uri.parse('$_emUrl/cart');
    final headers = {'Content-Type': 'application/json'};
    // Отправка запроса
    final response = await http.post(url, headers: headers, body: bd);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body)['id'] as String;
    } else {
      throw Exception('Ошибка: ${response.statusCode} ${response.body}');
    }
  }

  Future<String> deleteSelected(List<CartItem> selectedItems) async {
    final List<String> ids = selectedItems.map((item) => item.id).toList();
    final body = json.encode({"ids": ids});
    final url = Uri.parse('$_emUrl/cart');
    final headers = {'Content-Type': 'application/json'};
    // Отправка запроса
    final response = await http.delete(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return "Успех: ${json.decode(response.body)}";
    } else {
      throw Exception('Ошибка: ${response.statusCode} ${response.body}');
    }
  }

  Future<String> deleteFromCart(String itemId) async {
    final url = Uri.parse('$_emUrl/cart/$itemId');
    // Отправка запроса
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return "Успех: ${json.decode(response.body)}";
    } else {
      throw Exception('Ошибка: ${response.statusCode} ${response.body}');
    }
  }

  Future<String> updateCartItem(Map input) async {
    final body = json.encode(input);
    final url = Uri.parse('$_emUrl/cart');
    final headers = {'Content-Type': 'application/json'};
    // Отправка запроса
    final response = await http.patch(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return "Успех: ${json.decode(response.body)}";
    } else {
      throw Exception('Ошибка: ${response.statusCode} ${response.body}');
    }
  }
}

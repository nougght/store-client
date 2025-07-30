import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_store/classes.dart';

class ApiService {
  final String _emUrl = "https://26aef7d5e7a1.ngrok-free.app";
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

  Future<String> addToCart(Map item) async {
    final body = json.encode(item);
    final url = Uri.parse('$_emUrl/cart');
    final headers = {'Content-Type': 'application/json'};
    // Отправка запроса
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return "Успех: ${json.decode(response.body)}";
    } else {
      throw Exception('Ошибка: ${response.statusCode} ${response.body}');
    }
  }
}

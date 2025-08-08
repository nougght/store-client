import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_store/classes.dart';

class ApiService {
  // final String _emUrl = "http://10.0.2.2:8080";
  final String _emUrl = "http://51.250.104.71:8080";
  final String _localUrl = "http://127.0.0.1";

  var token = '';

  void setToken(String token) => this.token = token;

  Future<AuthCode> sendCode(AuthCode code) async {
    final bd = json.encode(code);
    final response = await http.post(Uri.parse("$_emUrl/auth/code/send"), body: bd);

    if (response.statusCode == 200) {
      return AuthCode.fromJson(json.decode(response.body)['code']);
    } else {
      throw Exception('Ошибка: ${response.statusCode} ${response.body}');
    }
  }

  Future<bool> verifyCode(String code, String recipient) async {
    final bd = json.encode({'code': code, 'recipient': recipient});
    final response = await http.post(Uri.parse("$_emUrl/auth/code/verify"), body: bd);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Ошибка: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<dynamic>> register(User user, AuthCode code) async {
    final bd = <String, dynamic>{'user': user.toJson(), 'code': code.toJson()};
    final response = await http.post(Uri.parse("$_emUrl/auth/register"), body: json.encode(bd));
    if (response.statusCode == 200) {

      return [
        User.fromJson(json.decode(response.body)['user']),
        Session.fromJson(json.decode(response.body)['session']),
      ];
    } else {
      throw Exception('Ошибка: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<dynamic>> login(User user, AuthCode code) async {
    final bd = <String, dynamic>{'user': user.toJson(), 'code': code.toJson()};
    final response = await http.post(Uri.parse("$_emUrl/auth/login"), body: json.encode(bd));
    if (response.statusCode == 200) {
      return [
        User.fromJson(json.decode(response.body)['user']),
        Session.fromJson(json.decode(response.body)['session']),
      ];
    } else {
      throw Exception('Ошибка: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<dynamic>> autoLogin(String userId, String token) async {
    final response = await http.post(
      Uri.parse("$_emUrl/auth/check"),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final userData = await http.get(
        Uri.parse("$_emUrl/user/$userId"),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
      if (userData.statusCode == 200) {
        final sessionData = await http.get(
          Uri.parse("$_emUrl/user/$userId/session"),
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        );
        if (sessionData.statusCode == 200) {
          // var decoded = ;
          return [
            User.fromJson(json.decode(userData.body)["user"]),
            Session.fromJson(json.decode(sessionData.body)["session"]),
          ];
        } else {
          throw Exception('Ошибка: ${sessionData.statusCode} ${sessionData.body}');
        }
      } else {
        throw Exception('Ошибка: ${userData.statusCode} ${userData.body}');
      }
    } else {
      throw Exception('Ошибка: ${response.statusCode} ${response.body}');
    }
  }

  Future<String> checkUser(String email_or_phone) async {
    final response = await http.post(Uri.parse("$_emUrl/user/check/$email_or_phone"));

    if (response.statusCode == 200) {
      final userId = json.decode(response.body)['user_id'];
      return userId ?? "";
    } else {
      throw Exception('Ошибка: ${response.statusCode} ${response.body}');
    }
  }

  Future<User> fetchUser(String userId) async {
    final response = await http.get(Uri.parse("$_emUrl/user/$userId"));
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body)['user']);
    } else {
      throw Exception('Ошибка: ${response.statusCode} ${response.body}');
    }
  }

  Future<bool> logout(String userId) async {
    final response = await http.post(Uri.parse("$_emUrl/user/logout/$userId"));
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Ошибка: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse("$_emUrl/products"));
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List).map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Ошибка загрузки продуктов: ${response.statusCode}');
    }
  }

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse("$_emUrl/categories"));

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List).map((item) => Category.fromJson(item)).toList();
      // print(data);
    } else {
      throw Exception('Ошибка загрузки категорий: ${response.statusCode}');
    }
  }

  Future<String> GetCartIdByUserId(String userId) async {
    final response = await http.get(Uri.parse("$_emUrl/cart/$userId"));
    if (response.statusCode == 200) {
      return json.decode(response.body)['cart_id'];
    } else {
      throw Exception('Ошибка загрузки корзины: ${response.statusCode} ${response.body}');
    }
  }

  Future<String> CreateCart(String userId) async {
    final response = await http.post(Uri.parse("$_emUrl/cart/$userId"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body)['cart_id'];
    } else {
      throw Exception('Ошибка загрузки корзины: ${response.statusCode} ${response.body}');
    }
  }
  Future<List<CartItem>> fetchCartItems({required String id}) async {
    final response = await http.get(Uri.parse("$_emUrl/cart/items/$id"));

    if (response.statusCode == 200) {
      var decoded = json.decode(response.body);
      return decoded is List
          ? (decoded as List).map((item) => CartItem.fromJson(item)).toList()
          : [];
    } else {
      throw Exception('Ошибка загрузки корзины: ${response.statusCode}${response.body}');
    }
  }

  Future<List<Product>> fetchProductsByIds(String query) async {
    final response = await http.get(Uri.parse("$_emUrl/products?ids=$query"));
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List).map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Ошибка загрузки продуктов в корзине: ${response.statusCode}');
    }
  }

  Future<FavouriteItem> addToFavourites(String productId, String userId) async {
    final url = Uri.parse('$_emUrl/user/$userId/favourites');
    final headers = {'Content-Type': 'application/json'};

    // Отправка запроса
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode({"product_id": productId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return FavouriteItem.fromJson(json.decode(response.body));
    } else {
      throw Exception('Ошибка: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<FavouriteItem>> fetchFavourites(String userId) async {
    final url = Uri.parse('$_emUrl/user/$userId/favourites');
    // Отправка запроса
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded == null) {
        return [];
      }
      return (decoded as List).map((item) => FavouriteItem.fromJson(item)).toList();
    } else {
      throw Exception('Ошибка загрузки избранного: ${response.statusCode} ${response.body}');
    }
  }

  Future<String> deleteFromFavourites(String productId, userId) async {
    final url = Uri.parse(
      '$_emUrl/user/$userId/favourites/$productId',
    );
    // Отправка запроса
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return "Успех: ${json.decode(response.body)}";
    } else {
      throw Exception('Ошибка: ${response.statusCode} ${response.body}');
    }
  }

  Future<String> addToCart(CartItem item) async {
    final bd = json.encode(item);
    final url = Uri.parse('$_emUrl/cart/items');
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
    final url = Uri.parse('$_emUrl/cart/items');
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
    final url = Uri.parse('$_emUrl/cart/items/$itemId');
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
    final url = Uri.parse('$_emUrl/cart/items');
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

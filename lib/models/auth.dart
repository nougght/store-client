import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_store/classes.dart';
import 'package:mobile_store/services/api_service.dart';
import 'cart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthModel with ChangeNotifier {
  final ApiService api;

  User? currentUser;
  Session? currentSession;

  bool _isSplashScreen = false;
  bool _isAuth = false;
  bool _isCodeSent = false;
  bool _isLoading = false;
  AuthCode? code;

  bool isRegistration = false;
  bool favouritesLoaded = false;


  List<FavouriteItem> favourites = [];

  // Геттеры
  bool get isAuth => _isAuth;
  bool get isCodeSent => _isCodeSent;
  bool get isLoading => _isLoading;
  bool get isSplashScreen => _isSplashScreen;

  String error = "";

  AuthModel(this.api) {
    currentUser = null;
    currentSession = null;
    _isSplashScreen = true;

  }

  
  
  Future<void> _saveToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', currentSession!.token);
    await prefs.setString('userId', currentSession!.userId);
  }

  // Методы
  Future<bool> sendCode(String? recipient, String channel) async {
    _isLoading = true;
    notifyListeners();

    code = AuthCode(recipient: recipient, channel: channel);

    try {
      code = await api.sendCode(code!);
      _isCodeSent = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка при отправке кода: $e');
      error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyCode(String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      final isValid = await api.verifyCode(code, this.code!.recipient ?? "");
      _isLoading = false;
      notifyListeners();
      return isValid; // Успешная проверка
    } catch (e) {
      debugPrint('Ошибка при проверке кода: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String> checkUser(String email_or_phone) async {
    try {
      final userId = await api.checkUser(email_or_phone);
      isRegistration = userId == "" ? true : false;
      notifyListeners();
      return userId; // Успешная проверка
    } catch (e) {
      debugPrint('Ошибка при проверке пользователя: $e');
      return "";
    }
  }

  Future<bool> register(String username) async {
    currentUser = User(username: username);
    if (isCodeSent) {
      if (code!.channel == "email") {
        currentUser!.email = code!.recipient ?? "";
      } else {
        currentUser!.phone = code!.recipient ?? "";
      }
    }

    
    try {
      final response = await api.register(currentUser!, code!);
      currentUser = response[0];
      currentSession = response[1];
      api.setToken(currentSession!.token);
      _saveToken();
      final cart_id = await api.CreateCart(currentUser!.userId);
      _isAuth = true;

      fetchFavourites();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка при регистрации пользователя: $e');
      return false;
    }
  }


  // Future<void> login(String number, String code) async {
  //   // временно
  //   userId = "085ed1df-58f5-43fc-8f67-1d9de231d9a8";
  //   cart.getCartId(userId);
  // }

  Future<bool> login(String userId) async {
    currentUser = User(userId: userId);
    if (isCodeSent) {
      if (code!.channel == "email") {
        currentUser!.email = code!.recipient ?? "";
      } else {
        currentUser!.phone = code!.recipient ?? "";
      }
    }

    try {
      final response = await api.login(currentUser!, code!);
      
      currentUser = response[0];
      currentSession = response[1];
      api.setToken(currentSession!.token);
      _isAuth = true;
      fetchFavourites();
      _saveToken();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка при входе в аккаунт: $e');
      return false;
    }

  }

  Future<void> _resetToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
  }

  Future<bool> logout() async {
    try {
      await api.logout(currentUser!.userId);
      _isAuth = false;
      currentUser = null;
      currentSession = null;
      isRegistration = false;
      _isCodeSent = false;
      api.setToken("");
      await _resetToken();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка при выходе из аккаунта: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> autoLogin(String token, String userId) async {
    if (token == "" || userId == "") {
      _isSplashScreen = false;
      notifyListeners();
      return false;
    }
    _isSplashScreen = true;
    var timePassed = false;
    final timer = Future.delayed(Duration(seconds: 1), (){timePassed = true;});
    try {
      final response = await api.autoLogin(userId, token);

      currentUser = response[0];
      currentSession = response[1];
      api.setToken(token);
      _isAuth = true;
      fetchFavourites();
      await timer;
      _isSplashScreen = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка при автоматическом входе в аккаунт: $e');
      await timer;
      _isSplashScreen = false;
      notifyListeners();
      return false;
    }
  }

  bool isProductInFavourites(String productId) {
    return favourites.any((item) => item.productId == productId);
  }

  Future<bool> addToFavourites(String productId) async {
    try {
      final response = await api.addToFavourites(productId, currentUser!.userId);
      favourites.add(response);
      notifyListeners();
      return true; // Успешное добавление
    } catch (e) {
      debugPrint('Ошибка при добавлении в избранное: $e');
      return false; // Ошибка при добавлении
    }
  }

  Future<bool> deleteFromFavourites(String productId) async {
    try {
      final response = await api.deleteFromFavourites(productId, currentUser!.userId);
      favourites.removeWhere((item) => item.productId == productId);
      notifyListeners();
      return true; // Успешное удаление
    } catch (e) {
      debugPrint('Ошибка при удалении из избранного: $e');
      return false;
    }
  }

  Future<void> fetchFavourites() async {
    try {
      favourites = await api.fetchFavourites(currentUser!.userId);
      favouritesLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка загрузки избранного: $e');
    }
  }

  Future<List<Product>> fetchProductsFromFavourites() async {
    if (favourites.isEmpty) {
      // productsLoaded = true;
      debugPrint('Корзина пуста, загрузка продуктов не требуется.');
    } else {
      String query = "";
      for (var item in favourites) {
        query += item.productId + ",";
      }
      query = query.substring(0, query.length - 1);
      debugPrint(query);
      try {
        final response = await api.fetchProductsByIds(query);

        // productsLoaded = true;
        return response;
      } catch (e) {
        debugPrint('Ошибка загрузки продуктов: $e');
      }
    }
    notifyListeners();
    return [];
  }
}

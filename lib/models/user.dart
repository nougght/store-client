import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_store/classes.dart';
import 'package:mobile_store/services/api_service.dart';
import 'cart.dart';



class UserModel with ChangeNotifier {
  final ApiService api;
  bool _isAuth = true;
  String? _phone;
  String? _smsCode;
  bool _isCodeSent = false;
  bool _isLoading = false;

  // Геттеры
  bool get isAuth => _isAuth;
  String? get phone => _phone;
  String? get smsCode => _smsCode;
  bool get isCodeSent => _isCodeSent;
  bool get isLoading => _isLoading;

  String? userId;
  CartModel cart;

  
  UserModel(this.api) : cart = CartModel(api);

  Future<void> login(String number, String code) async {
    // временно
    userId = "085ed1df-58f5-43fc-8f67-1d9de231d9a8";
    cart.getCartId(userId);
  }

  // Методы
  Future<void> sendCode(String phone) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(seconds: 1)); // Имитация запроса к API
      _phone = phone;
      _isCodeSent = true;
      // notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyCode(String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(seconds: 1)); // Имитация проверки кода
      _smsCode = code;
      return true; // Успешная проверка
    } finally {
      _isLoading = false;
      _isAuth = true;
      notifyListeners();
    }
  }

  void reset() {
    _phone = null;
    _smsCode = null;
    _isCodeSent = false;
    notifyListeners();
  }
}

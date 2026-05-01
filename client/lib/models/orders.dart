import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_store/classes.dart';
import 'package:mobile_store/services/api_service.dart';
import 'auth.dart';

// class OrderItem
String OrderStatusToString(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return "Обрабатывается";
    case OrderStatus.transit:
      return "В пути";
    case OrderStatus.delivered:
      return "Доставлен";
    case OrderStatus.completed:
      return "Завершен";
    case OrderStatus.cancelled:
      return "Отменен";
  }
}

class OrderModel with ChangeNotifier {
  final ApiService api;
  final AuthModel auth;
  bool ordersLoaded = false;
  List<Order> orders = [];
  bool isAllChecked = false;
  OrderModel(this.api, this.auth);


  List<Order> get currentOrders => orders.where((order) => order.status != OrderStatus.completed && order.status != OrderStatus.cancelled).toList();
  List<Order> get completedOrders => orders.where((order) => order.status == OrderStatus.completed || order.status == OrderStatus.cancelled).toList();

  Future<void> fetchOrders() async {
    try {
      final response = await api.fetchOrders(auth.currentUser!.userId);
      orders = response;
      ordersLoaded = true;
    } catch (e) {
      debugPrint('Ошибка загрузки заказов: $e');
    }
    notifyListeners();
  }

  Future<String> addOrder(Order order) async {
    try {
      final id = await api.createOrder(order);
      order.id = id;
      debugPrint('Заказ создан: $id');
      orders = [...orders, order];
      notifyListeners();
      return id;
    } catch (e) {
      debugPrint('Ошибка создания заказа: $e');
      return "";
    }
  }

  Future<bool> addOrderItems(List<OrderItem> items) async {
    try {
      await api.createOrderItems(items);
      debugPrint('Товары добавлены в заказ');
      return true;
    } catch (e) {
      debugPrint('Ошибка добавления товаров в заказ: $e');
      return false;
    }
  }

  Future<bool> addDelivery(Delivery delivery) async {
    try {
      await api.createDelivery(delivery);
      debugPrint('Доставка создана');
      return true;
    } catch (e) {
      debugPrint('Ошибка создания доставки: $e');
      return false;
    }
  }

}

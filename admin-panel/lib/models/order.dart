import 'package:flutter/foundation.dart';
import 'package:admin_panel/api_client.dart';



class Delivery {
  String id;
  String orderId;
  String address;
  double latitude;
  double longitude;
  double distanceKm;
  double packageWeight;
  int packageSize;
  DeliveryStatus status;
  DateTime scheduledAt;
  DateTime? deliveredAt;

  Delivery({
    this.id = "",
    this.orderId = "",
    this.address = "",
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.distanceKm = 0.0,
    this.packageWeight = 0.0,
    this.packageSize = 0,
    this.status = DeliveryStatus.pending,
    DateTime? scheduledAt,
    this.deliveredAt,
  }) : this.scheduledAt = scheduledAt ?? DateTime.now().add(Duration(days: 1));

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] ?? "",
      orderId: json['order_id'] ?? "",
      address: json['address'] ?? "",
      latitude: json['latitude'].toDouble() ?? 0.0,
      longitude: json['longitude'].toDouble() ?? 0.0,
      distanceKm: json['distance_km'].toDouble() ?? 0.0,
      packageWeight: json['package_weight'].toDouble() ?? 0.0,
      packageSize: json['package_size'] ?? 0,
      status: DeliveryStatus.values.byName(json['status'] ?? "pending"),
      scheduledAt: DateTime.parse(json['scheduled_at']) ?? DateTime.now(),
      deliveredAt: json['delivered_at'] == null ? null : DateTime.parse(json['delivered_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'distance_km': distanceKm,
      'package_weight': packageWeight,
      'package_size': packageSize,
      'status': status.name,
      'scheduled_at': scheduledAt.toUtc().toIso8601String(),
      'delivered_at': deliveredAt?.toUtc().toIso8601String(),
    };
  }
}

enum DeliveryStatus { pending, transit, delivered }

class Order {
  String id;
  String userId;
  OrderStatus status;
  double totalPrice;
  double deliveryPrice;
  String paymentMethod;
  DateTime createdAt;
  DateTime updatedAt;
  List<OrderItem> items;
  Delivery delivery;

  Order({
    this.id = "",
    this.userId = "",
    this.status = OrderStatus.pending,
    this.totalPrice = 0.0,
    this.deliveryPrice = 0.0,
    this.paymentMethod = "",
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItem>? items,
    Delivery? delivery,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       items = items ?? [],
       this.delivery = delivery ?? Delivery();

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"],
    userId: json["user_id"],
    status: OrderStatus.values.byName(json["status"]),
    totalPrice: json["total_price"],
    deliveryPrice: (json["delivery_price"] as num).toDouble(),
    paymentMethod: json["payment_method"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    items: List<OrderItem>.from((json["items"] as List).map((x) => OrderItem.fromJson(x))),
    delivery: json["delivery"] != null ? Delivery.fromJson(json["delivery"]) : Delivery(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "status": status.name,
    "total_price": totalPrice,
    "delivery_price": deliveryPrice,
    "payment_method": paymentMethod,
    "created_at": createdAt.toUtc().toIso8601String(),
    "updated_at": updatedAt.toUtc().toIso8601String(),
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
    "delivery": delivery.toJson(),
  };
}

enum OrderStatus { pending, transit, delivered, completed, cancelled }

class OrderItem {
  String id;
  String orderId;
  String productId;
  int quantity;
  double price;
  double? weight;

  OrderItem({
    this.id = "",
    this.orderId = "",
    this.productId = "",
    this.quantity = 1,
    this.price = 0.0,
    this.weight,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json["id"],
    orderId: json["order_id"],
    productId: json["product_id"],
    quantity: json["quantity"],
    price: json["price"],
    weight: json["weight"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "product_id": productId,
    "quantity": quantity,
    "price": price,
    if (weight != null) "weight": weight,
  };
}

class OrderModel with ChangeNotifier {
  final ApiService api;
  // final AuthModel auth;
  bool ordersLoaded = false;
  List<Order> orders = [];
  bool isAllChecked = false;
  Order? selectedOrder;

  OrderModel(this.api);

  List<Order> get activeOrders => orders
      .where(
        (order) => order.status != OrderStatus.completed || order.status != OrderStatus.cancelled,
      )
      .toList();
  List<Order> get newOrders => orders
      .where(
        (order) => order.status == OrderStatus.pending,
      )
      .toList();
  List<Order> get completedOrders => orders

      .where(
        (order) => order.status == OrderStatus.completed || order.status == OrderStatus.cancelled,
      )
      .toList();

  void selectOrder(Order order) {
    selectedOrder = order;
    notifyListeners();
  }
  
  Future<void> fetchOrders(String status) async {
    try {
      // ordersLoaded = false;
      final response = await api.fetchOrders(status);
      orders += response;
      ordersLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка загрузки заказов: $e');
    }
  }
  Future<void> updateOrder(Order order) async {
    try {
      await api.updateOrder(order);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка обновления заказа: $e');
    }
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

  // Future<bool> addOrderItems(List<OrderItem> items) async {
  //   try {
  //     await api.createOrderItems(items);
  //     debugPrint('Товары добавлены в заказ');
  //     return true;
  //   } catch (e) {
  //     debugPrint('Ошибка добавления товаров в заказ: $e');
  //     return false;
  //   }
  // }

  // Future<bool> addDelivery(Delivery delivery) async {
  //   try {
  //     await api.createDelivery(delivery);
  //     debugPrint('Доставка создана');
  //     return true;
  //   } catch (e) {
  //     debugPrint('Ошибка создания доставки: $e');
  //     return false;
  //   }
  // }
}

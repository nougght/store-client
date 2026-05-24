import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_store/models/cacheManager.dart';
import 'package:mobile_store/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/enums.dart';

final nilUuid = Namespace.nil.value;

class Product {
  Product({
    String id = "",
    this.name = "product_name",
    this.description = "",
    this.price = 0.0,
    String categoryId = "",
    this.quantity = 0.0,
    this.unit = "шт",
    List<String>? images,
    this.hasImage = true,
    this.stock = 0,
    DateTime? creationDate,
  }) : id = id.isEmpty ? nilUuid : id,
       categoryId = categoryId.isEmpty ? nilUuid : categoryId,
       images = images ?? const [],
       creationDate = creationDate ?? DateTime.now();

  String id;
  String name;
  String description;
  double price;
  double quantity;
  String unit;
  String categoryId;
  List<String> images;
  bool hasImage;
  int stock;
  DateTime creationDate;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? "",
      name: json['name'] ?? "category_name",
      description: json['description'] ?? "",
      price: json['price'].toDouble() ?? 0.0,
      categoryId: json['category_id'] ?? "",
      quantity: json['quantity'].toDouble() ?? 1.0,
      unit: json['unit'] ?? "шт",

      images: json['images'] ?? [],
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
      'images': images,
      'stock': stock,
      'created_at': creationDate.toUtc().toIso8601String(),
    };
  }

  Future<void> precache(String url, BuildContext context) async {
    await precacheImage(
      FileImage(await MyCacheManager().getSingleFile(url)),
      context,
    );
  }

  Future<List<String>> getImages(BuildContext context) async {
    try {
      if (images.isNotEmpty || hasImage == false) {
        return images;
      }
      List<String> imgs = await ApiService.GetImages(this.id);
      if (imgs.isNotEmpty) {
        this.images = imgs;
        hasImage = true;
        List<Future<void>> Futures = [];
        var file;
        for (var image in images) {
          Futures.add(precache(image, context));
        }
        await compute((_) async {
          await Future.wait(Futures);
        }, null);
        // debugPrint(name);
      } else {
        images = [];
        hasImage = false;
      }
      return images;
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> refreshImages() async {
    try {
      List<String> imgs = await ApiService.GetImages(this.id);
      if (imgs.isNotEmpty) {
        this.images = imgs;
        hasImage = true;
      } else {
        images = [];
        hasImage = false;
      }
      return images;
    } catch (e) {
      return [];
    }
  }
}

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
    String id = "",
    String orderId = "",
    this.address = "",
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.distanceKm = 0.0,
    this.packageWeight = 0.0,
    this.packageSize = 0,
    this.status = DeliveryStatus.pending,
    DateTime? scheduledAt,
    this.deliveredAt,
  }) : id = id.isEmpty ? nilUuid : id,
       orderId = orderId.isEmpty ? nilUuid : orderId,
       scheduledAt = scheduledAt ?? DateTime.now().add(Duration(days: 1));

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
      deliveredAt: json['delivered_at'] == null
          ? null
          : DateTime.parse(json['delivered_at']),
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
    String id = "",
    String userId = "",
    this.status = OrderStatus.pending,
    this.totalPrice = 0.0,
    this.deliveryPrice = 0.0,
    this.paymentMethod = "",
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItem>? items,
    Delivery? delivery,
  }) : id = id.isEmpty ? nilUuid : id,
       userId = userId.isEmpty ? nilUuid : userId,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       items = items ?? [],
       this.delivery = delivery ?? Delivery();

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"],
    userId: json["user_id"],
    status: OrderStatus.values.byName(json["status"]),
    totalPrice: (json["total_price"] as num).toDouble(),
    deliveryPrice: (json["delivery_price"] as num).toDouble(),
    paymentMethod: json["payment_method"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    items: List<OrderItem>.from(
      (json["items"] as List).map((x) => OrderItem.fromJson(x)),
    ),
    delivery: json["delivery"] != null
        ? Delivery.fromJson(json["delivery"])
        : Delivery(),
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
    String id = "",
    String orderId = "",
    String productId = "",
    int quantity = 1,
    double price = 0.0,
    double? weight,
  }) : id = id.isEmpty ? nilUuid : id,
       orderId = orderId.isEmpty ? nilUuid : orderId,
       productId = productId.isEmpty ? nilUuid : productId,
       quantity = quantity,
       price = price,
       weight = weight;

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

class CartItem {
  CartItem({
    String id = "",
    String cart_id = "",
    String productId = "",
    int quantity = 0,
    bool isChecked = false,
  }) : id = id.isEmpty ? nilUuid : id,
       cart_id = cart_id.isEmpty ? nilUuid : cart_id,
       productId = productId.isEmpty ? nilUuid : productId,
       quantity = quantity,
       isChecked = isChecked;

  String id;
  String cart_id;
  String productId;
  int quantity;
  bool isChecked;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? "",
      cart_id: json['cart_id'] ?? "",
      productId: json['product_id'] ?? "",
      quantity: json['quantity'] ?? 0,
      isChecked: json['is_checked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cart_id,
      'product_id': productId,
      'quantity': quantity,
      'is_checked': isChecked,
    };
  }
}

class FavouriteItem {
  FavouriteItem({
    String userId = "",
    String productId = "",
    DateTime? createdAt,
  }) : userId = userId.isEmpty ? nilUuid : userId,
       productId = productId.isEmpty ? nilUuid : productId,
       createdAt = createdAt ?? DateTime.now();

  String userId;
  String productId;
  DateTime createdAt;

  factory FavouriteItem.fromJson(Map<String, dynamic> json) {
    return FavouriteItem(
      userId: json['user_id'] ?? "",
      productId: json['product_id'] ?? "",
      createdAt: DateTime.parse(json['created_at']) ?? DateTime.now(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'product_id': productId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Category {
  Category({
    String id = "",
    this.name = "category_name",
    this.description = "",
    this.image = "",
  }) : id = id.isEmpty ? nilUuid : id;

  String id;
  String name;
  String description;
  String image;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? "",
      name: json['name'] ?? "category_name",
      description: json['description'] ?? "",
      image: json['image'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}

class User {
  String userId;
  String email;
  String phone;
  DateTime? createdAt;
  DateTime? lastActive;
  String username;

  User({
    String userId = "",
    this.email = "",
    this.phone = "",
    this.createdAt,
    this.lastActive,
    this.username = "",
  }) : userId = userId.isEmpty ? nilUuid : userId;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? "",
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at']),
      lastActive: json['last_active'] == null
          ? null
          : DateTime.parse(json['last_active']),
      username: json['username'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'phone': phone,
      'created_at': createdAt?.toIso8601String(),
      'last_active': lastActive?.toIso8601String(),
      'username': username,
    };
  }
}

class Session {
  String sessionId;
  String userId;
  String token;
  String? deviceInfo;
  String? ipAddress;
  DateTime? createdAt;
  DateTime? expiresAt;

  Session({
    String sessionId = "",
    String userId = "",
    this.token = "",
    this.deviceInfo,
    this.ipAddress,
    this.createdAt,
    this.expiresAt,
  }) : sessionId = sessionId.isEmpty ? nilUuid : sessionId,
       userId = userId.isEmpty ? nilUuid : userId;

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['session_id'] ?? "",
      userId: json['user_id'] ?? "",
      token: json['token'] ?? "",
      deviceInfo: json['device_info'],
      ipAddress: json['ip_address'],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'user_id': userId,
      'token': token,
      'device_info': deviceInfo,
      'ip_address': ipAddress,
      'created_at': createdAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}

class AuthCode {
  String id;
  String userId;
  String code;
  String channel;
  DateTime? expiresAt;
  bool used;
  String? ipAddress;
  String? recipient;

  AuthCode({
    String id = "",
    String userId = "",
    this.code = "",
    this.channel = "",
    this.expiresAt,
    this.used = false,
    this.ipAddress,
    this.recipient,
  }) : id = id.isEmpty ? nilUuid : id,
       userId = userId.isEmpty ? nilUuid : userId;

  factory AuthCode.fromJson(Map<String, dynamic> json) {
    return AuthCode(
      id: json['code_id'] ?? "",
      userId: json['user_id'] ?? "",
      code: json['code'] ?? "",
      channel: json['channel'] ?? "",
      expiresAt: DateTime.parse(json['expires_at']),
      used: json['used'] ?? false,
      ipAddress: json['ip_address'],
      recipient: json['recipient'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code_id': id,
      'user_id': userId,
      'code': code,
      'channel': channel,
      'expires_at': expiresAt?.toIso8601String(),
      'used': used,
      'ip_address': ipAddress,
      'recipient': recipient,
    };
  }
}

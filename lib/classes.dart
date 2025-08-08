import 'dart:convert';

class Product {
  Product({
    this.id = "",
    this.name = "product_name",
    this.description = "",
    this.price = 0.0,
    this.categoryId = "",
    this.quantity = 0.0,
    this.unit = "шт",
    List<String>? images,
    this.stock = 0,
    DateTime? creationDate,
  }) : images = images ?? const [],
       creationDate = creationDate ?? DateTime.now();

  String id;
  String name;
  String description;
  double price;
  double quantity;
  String unit;
  String categoryId;
  List<String> images;
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
      'created_at': creationDate.toIso8601String(),
    };
  }
}

class CartItem {
  CartItem({
    this.id = "",
    this.cart_id = "",
    this.productId = "",
    this.quantity = 0,
    this.isChecked = false,
  });

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
  FavouriteItem({this.userId = "", this.productId = "", DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();

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
    return {'user_id': userId, 'product_id': productId, 'created_at': createdAt.toIso8601String()};
  }
}

class Category {
  Category({this.id = "", this.name = "category_name", this.description = "", this.image = ""});

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
    this.userId = "",
    this.email = "",
    this.phone = "",
    this.createdAt,
    this.lastActive,
    this.username = "",
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? "",
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at']),
      lastActive: json['last_active'] == null ? null : DateTime.parse(json['last_active']),
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
    this.sessionId = "",
    this.userId = "",
    this.token = "",
    this.deviceInfo,
    this.ipAddress,
    this.createdAt,
    this.expiresAt,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['session_id'] ?? "",
      userId: json['user_id'] ?? "",
      token: json['token'] ?? "",
      deviceInfo: json['device_info'],
      ipAddress: json['ip_address'],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: json['expires_at'] == null ? null : DateTime.parse(json['expires_at']),
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
    this.id = "",
    this.userId = "",
    this.code = "",
    this.channel = "",
    this.expiresAt,
    this.used = false,
    this.ipAddress,
    this.recipient,
  });

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

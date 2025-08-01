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

class Category {
  Category({
    this.id = "",
    this.name = "category_name",
    this.description = "",
    this.image = "",
  });

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

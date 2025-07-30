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

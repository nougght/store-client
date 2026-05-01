import 'package:dio/dio.dart';
import 'package:admin_panel/models/product.dart';
import 'package:admin_panel/models/category.dart';
import 'package:admin_panel/models/order.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
// import 'dart:io';

import 'package:flutter/widgets.dart';

final baseUrl = 'http://localhost:8080';

class ApiService {
  final _dio = Dio(
    BaseOptions(
      // baseUrl 'http://51.250.104.71:8080',
      validateStatus: (status) => true,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // товары

  Future<List<Product>> fetchProducts() async {
    final response = await _dio.get('$baseUrl/products');
    if (response.statusCode != 200)
      throw Exception(
        'Ошибка получения продуктов' + response.statusCode.toString() + response.data.toString(),
      );
    final data = response.data as List;
    return data.map((e) => Product.fromJson(e)).toList();
  }

  Future<Product> createProduct(Product product) async {
    final response = await _dio.post(
      '$baseUrl/products',
      data: jsonEncode(product),
    );
    if (response.statusCode != 200)
      throw Exception(
        'Ошибка создания продукта' + response.statusCode.toString() + response.data.toString(),
      );
    product.id = response.data['id'];
    return product;
  }

  Future<Product> updateProduct(String productId, Product product) async {
    final response = await _dio.put(
      '$baseUrl/products/$productId',
      data: jsonEncode(product),
    );
    if (response.statusCode != 200)
      throw Exception(
        'Ошибка обновления продукта' + response.statusCode.toString() + response.data.toString(),
      );
    return product;
  }

  Future<void> deleteProduct(String productId) async {
    final response = await _dio.delete('$baseUrl/products/$productId');
    if (response.statusCode != 200)
      throw Exception(
        'Ошибка удаления продукта' + response.statusCode.toString() + response.data.toString(),
      );
  }

  // категории

  Future<List<Category>> fetchCategories() async {
    final response = await _dio.get('$baseUrl/categories');
    if (response.statusCode != 200)
      throw Exception(
        'Ошибка получения категорий' + response.statusCode.toString() + response.data.toString(),
      );
    final data = response.data as List;
    return data.map((e) => Category.fromJson(e)).toList();
  }

  Future<Category> createCategory(Category category) async {
    final response = await _dio.post(
      '$baseUrl/categories',
      data: jsonEncode(category),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Ошибка создания категории' + response.statusCode.toString() + response.data.toString(),
      );
    }
    category.id = response.data["id"];
    return category;
  }

  Future<Category> updateCategory(String categoryId, Category category) async {
    try {
      final response = await _dio.put(
        '$baseUrl/categories/$categoryId',
        data: jsonEncode(category),
      );
      return category;
    } catch (e) {
      throw Exception('Ошибка обновления категории: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _dio.delete('$baseUrl/categories/$categoryId');
    } catch (e) {
      throw Exception('Ошибка удаления категории: $e');
    }
  }

  // заказы

  Future<List<Order>> fetchOrders(String status) async {
    final response = await _dio.get('$baseUrl/orders?status=$status');
    if (response.statusCode != 200)
      throw Exception(
        'Ошибка получения заказов' + response.statusCode.toString() + response.data.toString(),
      );
    final data = response.data as List;
    return data.map((e) => Order.fromJson(e)).toList();
  }

  Future<String> createOrder(Order order) async {
    final response = await _dio.post('$baseUrl/orders', data: jsonEncode(order));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data['id'] as String;
    } else {
      throw Exception('Ошибка: ${response.statusCode} ${response.data}');
    }
  }

  Future<String> updateOrder(Order order) async {
    final response = await _dio.put(
      '$baseUrl/order/${order.id}',
      data: jsonEncode(order),
    );

    if (response.statusCode == 200) {
      return 'Заказ обновлен успешно';
    } else {
      throw Exception('Ошибка: ${response.statusCode} ${response.data}');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _dio.delete('$baseUrl/orders/$orderId');
    } catch (e) {
      throw Exception('Ошибка удаления заказа: $e');
    }
  }

  // изображения

  Future<List<Map<String, dynamic>>> getProductImages(String productId) async {
    // presigned GET URLs
    debugPrint(productId);
    final response = await _dio.get('$baseUrl/products/$productId/images');
    debugPrint(response.data.toString());
    if (response.statusCode != 200) throw Exception('Failed to get presigned get urls');
    final data = response.data;
    if (data["images"] == null) return [];
    return (data["images"] as List).map((e) => e as Map<String, dynamic>).toList();
  }

  Future<String> getProductPresignedPut(String productId, int number, String ext) async {
    final response = await _dio.get(
      '$baseUrl/products/$productId/images/$number/upload_url/$ext',
    );
    debugPrint(response.data.toString());
    if (response.statusCode != 200) throw Exception('Failed to get presigned put url');
    final data = response.data["upload_url"];

    return data ?? "";
  }

  Future<void> uploadProductToPresignedUrl(
    String url,
    Uint8List fileBytes, {
    String? contentType,
  }) async {
    debugPrint("uploading image, size: ${fileBytes.length}, contentType: $contentType");
    final options = Options(headers: {'Content-Type': contentType ?? 'application/octet-stream'});
    final response = await _dio.put(url, data: fileBytes, options: options);
    if (response.statusCode != 200) throw Exception('Failed to upload image');
  }

  Future<void> deleteProductImage(String productId, int number, ext) async {
    final response = await _dio.delete(
      '$baseUrl/products/$productId/images/$number/$ext',
    );
    if (response.statusCode != 200) throw Exception('Failed to delete image');
  }

  Future<String> getCategoryImage(String categoryId) async {
    // presigned GET URLs
    // debugPrint(productId);
    final response = await _dio.get('$baseUrl/categories/$categoryId/image'
    );
    debugPrint(response.data.toString());
    if (response.statusCode != 200)
      throw Exception('Failed to get presigned get urls');
    final data = response.data;
    if (data["url"] == null) return "";
    return data["url"] as String;
  }

  Future<String> getCategoryPresignedPut(String categoryId, String ext) async {
    final response = await _dio.get(
      '$baseUrl/categories/$categoryId/image/upload_url/$ext',
    );
    debugPrint(response.data.toString());
    if (response.statusCode != 200) throw Exception('Failed to get presigned put url');
    final data = response.data["upload_url"];

    return data ?? "";
  }

  Future<void> uploadCategoryToPresignedUrl(String url, Uint8List fileBytes, {String? contentType}) async {
    final options = Options(headers: {'Content-Type': contentType ?? 'application/octet-stream'});
    final response = await _dio.put(url, data: fileBytes, options: options);
    if (response.statusCode != 200)
      throw Exception('Failed to upload image');
  }

  // Future<void> deleteProductImage(String productId, int number, ext) async {
  //   final response = await _dio.delete('$baseUrl/products/$productId/images/$number/$ext');
  //   if (response.statusCode != 200) throw Exception('Failed to delete image');
  // }
}

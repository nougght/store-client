// import 'dart:io';
// import 'package:dio/dio.dart';
// import '../models/product.dart';

// class ProductService {
//   final Dio _dio = Dio(BaseOptions(baseUrl: 'http://51.250.104.71:8080'));

//   Future<List<Product>> getProducts() async {
//     final res = await _dio.get('/products');
//     return (res.data as List).map((json) => Product.fromJson(json)).toList();
//   }

//   Future<void> deleteImage(String productId, String imageKey) async {
//     // await _dio.delete('/products/$productId/images/$imageKey');
//   }

//   Future<void> uploadImage(String productId, File file) async {
//     // final formData = FormData.fromMap({'file': await MultipartFile.fromFile(file.path)});
//     // await _dio.post('/products/$productId/images', data: formData);
//   }
// }

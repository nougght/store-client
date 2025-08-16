import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'classes.dart';
import 'cards.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'services/api_service.dart';
import 'models/product.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.api});
  final ApiService api;
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // final ApiService _api = ApiService();
  // List<Product> _products = [];
  bool isLoading = false;
  int page = 1;
  int limit = 20;
  Future<void> _loadProducts(int page, int limit) async {
    // _products = await widget.api.fetchProducts();
    final provider = context.read<ProductProvider>();
    if (isLoading) return;
    setState(() => isLoading = true);
    await provider.fetchList(key: "home", filters: {"sort" : "created_desc"}, page: page, limit: limit); // первая загрузка
    setState(() => isLoading = false);
    // setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadProducts(1, 20);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final products = provider.getList("home");

        return Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Color.fromARGB(255, 170, 230, 170),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                    pinned: true,
                    title: Text(
                      "Главная",
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      // IconButton(

                      // ),
                    ],
                  ),
                  SliverPadding(
                    padding: EdgeInsetsGeometry.all(10),
                    sliver: SliverGrid.builder(
                      itemBuilder: (context, i) {
                        if (i >= products.length) {
                          if (!isLoading) {
                            _loadProducts(++page, limit);
                          }
                          return Center(child: CircularProgressIndicator());
                        }
                        return ProductCard(product: products[i]);
                      },
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 7,
                        crossAxisSpacing: 4,
                        childAspectRatio: 0.6,
                      ),
                      itemCount: products.length + (isLoading ? 6 : 0),
                    ),
                  ),
                ],
              ),
              // Positioned(
              //   bottom: 0,
              //   left: 0,
              //   right: 0,
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              //     child: Container(
              //       decoration: BoxDecoration(
              //         color: Color.fromARGB(207, 185, 185, 185),
              //         // borderRadius: BorderRadius.only(
              //         //   topLeft: Radius.circular(20),
              //         //   topRight: Radius.circular(10),
              //         // ),
              //       ),
              //       padding: EdgeInsetsGeometry.only(
              //         left: 10,
              //         right: 10,
              //         top: 5,
              //         bottom: 20,
              //       ),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         spacing: 5,
              //         children: [
              //           Expanded(
              //             child: ElevatedButton(
              //               onPressed: () {},
              //               style: ElevatedButton.styleFrom(
              //                 backgroundColor: const Color.fromARGB(
              //                   255,
              //                   160,
              //                   213,
              //                   159,
              //                 ),
              //               ),
              //               child: Text(
              //                 "Купить",
              //                 style: TextStyle(fontSize: 25, height: 2),
              //               ),
              //             ),
              //           ),
              //           Expanded(
              //             child: ElevatedButton(
              //               onPressed: () {},
              //               style: ElevatedButton.styleFrom(
              //                 backgroundColor: const Color.fromARGB(
              //                   255,
              //                   159,
              //                   201,
              //                   213,
              //                 ),
              //               ),
              //               child: Text(
              //                 "В корзину",
              //                 style: TextStyle(fontSize: 25, height: 2),
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }
}

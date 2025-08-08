import 'package:flutter/material.dart';
import 'classes.dart';
import 'cards.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'services/api_service.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.api});
  final ApiService api;
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ApiService _api = ApiService();
  List<Product> _products = [];

  Future<void> _loadProducts() async {
    _products = await widget.api.fetchProducts();
    setState(() {});
  }
  @override
  initState() {
    super.initState();
    _loadProducts();
  }

  Widget gridBuild(BuildContext c, int i) {
    return ProductCard(product: _products[i]);
    // Placeholder();
  }

  @override
  Widget build(BuildContext context) {
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
              _products.isNotEmpty
                  ? SliverPadding(padding: EdgeInsetsGeometry.all(10), sliver: SliverGrid.builder(
                      itemBuilder: (context, i) {
                        return ProductCard(
                          product: _products[i],
                          
                        );
                      },
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 7,
                        crossAxisSpacing: 4,
                        childAspectRatio: 0.6,
                      ),
                      itemCount: _products.length,
                    ))
                  : SliverToBoxAdapter(
                      child: Center(
                        child: Column(
                          spacing: 20,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Загрузка...", style: TextStyle(fontSize: 30)),
                            CircularProgressIndicator(),
                          ],
                        ),
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
  }
}

import 'package:flutter/material.dart';
import 'package:mobile_store/cards.dart';

import 'package:flutter/foundation.dart';
import 'package:mobile_store/models/product.dart';
import 'package:mobile_store/payment_page.dart';
import 'package:mobile_store/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'classes.dart';
import 'models/cart.dart';
import 'payment_page.dart';

class CartPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // List<Product> products = [
  //   Product(
  //     name: "Хлеб",
  //     description: "Ржаной хлеб",
  //     price: 35.0,
  //     stock: 5,
  //   ),
  //   Product(
  //     name: "Молоко",
  //     description: "1 литр, 3.2%",
  //     price: 70.0,
  //     stock: 10,
  //   ),
  //   Product(
  //     name: "Смартфон",
  //     description: "Android, 128GB",
  //     price: 15999.0,
  //     stock: 3,
  //   ),
  //   Product(
  //     name: "Книга",
  //     description: "Роман, 350 стр.",
  //     price: 450.0,
  //     stock: 7,
  //   ),
  //   Product(
  //     name: "Футболка",
  //     description: "100% хлопок",
  //     price: 599.0,
  //     stock: 15,
  //   ),
  // ];

  @override
  initState() {
    super.initState();
    Future.microtask(() async {
      await _loadCart();
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  Future<void> _loadCart() async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    if (cartModel.cartId != null) {
      await cartModel.fetchCartItems(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProductProvider productProvider = Provider.of<ProductProvider>(context);
    return Consumer<CartModel>(
      builder: (context, cartModel, child) {
        final products = cartModel.products;
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async => await _loadCart(),
            // onRefresh: () => _loadCatalog(),
            child:
                // appBar: AppBar(
                //   backgroundColor: Color.fromARGB(248, 133, 231, 166),
                //   title: Text("Корзина", style: TextStyle(fontSize: 20)),
                //   actions: [Icon(Icons.delete_sweep_rounded)],
                // ),
                Stack(
                  children: [
                    // Positioned.fill(
                    //   child: Container(color: Color.fromARGB(255, 206, 212, 211)),
                    // ),
                    CustomScrollView(
                      slivers: <Widget>[
                        SliverAppBar(
                          backgroundColor: Color.fromARGB(255, 170, 230, 170),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.only(
                              bottomLeft: Radius.circular(25),
                              bottomRight: Radius.circular(25),
                            ),
                          ),
                          pinned: true,
                          title: Text('Корзина', style: TextStyle(fontSize: 20)),
                          actions: [
                            Checkbox(
                              value: cartModel.isAllChecked,
                              onChanged: (istrue) {
                                setState(() {
                                  cartModel.toggleSelectAll(istrue);
                                });
                              },
                            ),
                            IconButton(
                              onPressed: cartModel.cartItems.isNotEmpty
                                  ? () {
                                      cartModel.removeSelected(context);
                                      cartModel.isAllChecked = false;
                                    }
                                  : null,

                              icon: Icon(Icons.delete_sweep),
                            ),
                          ],
                        ),

                        cartModel.cartLoaded
                            ? cartModel.products.isEmpty
                                  ? SliverToBoxAdapter(
                                      child: Padding(
                                        padding: EdgeInsetsGeometry.symmetric(vertical: 50),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Text(
                                                "Добавьте товары в корзину",
                                                style: TextStyle(fontSize: 25),
                                              ),
                                              Icon(Icons.shopping_cart_outlined, size: 50),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : SliverPadding(
                                      padding: EdgeInsetsGeometry.only(
                                        left: 10,
                                        right: 10,
                                        top: 10,
                                        bottom: 80,
                                      ),
                                      sliver: SliverList(
                                        delegate: SliverChildBuilderDelegate((context, int i) {
                                          return InCartProductCard(
                                            product: cartModel.products[i],
                                            cartItemId: cartModel.cartItems[i].id,
                                          );
                                        }, childCount: cartModel.cartItems.length),
                                      ),
                                    )
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
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(207, 185, 185, 185),
                            // borderRadius: BorderRadius.only(
                            //   topLeft: Radius.circular(20),
                            //   topRight: Radius.circular(10),
                            // ),
                          ),
                          padding: EdgeInsetsGeometry.only(left: 5, right: 5, top: 5, bottom: 5),
                          child: ElevatedButton(
                            onPressed: () {
                              if (cartModel.cartLoaded && cartModel.cartItems.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => PaymentPage()),
                                );
                              } else {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text("Корзина пуста")));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(248, 133, 231, 166),
                              padding: EdgeInsetsGeometry.all(15),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text("Оформить заказ", style: TextStyle(fontSize: 20)),
                                Text(
                                  " (${cartModel.totalQuantity})",
                                  style: TextStyle(fontSize: 20),
                                ),
                                Expanded(child: Spacer()),
                                Text(
                                  "${cartModel.totalPrice.toStringAsFixed(2)} ₽",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          ),
        );
      },
    );
  }
}

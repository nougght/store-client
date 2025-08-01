import 'package:flutter/material.dart';
import 'package:mobile_store/cards.dart';

import 'package:flutter/foundation.dart';
import 'package:mobile_store/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'classes.dart';
import 'models/cart.dart';

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
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    await cartModel.fetchCartItems();
    if (cartModel.cartLoaded) {
      await cartModel.fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<CartModel>(
      builder: (context, cartModel, child) {
        return Scaffold(
          // appBar: AppBar(
          //   backgroundColor: Color.fromARGB(248, 133, 231, 166),
          //   title: Text("Корзина", style: TextStyle(fontSize: 20)),
          //   actions: [Icon(Icons.delete_sweep_rounded)],
          // ),
          body: CustomScrollView(
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
                  IconButton(onPressed: () {
                    cartModel.removeSelected();
                  }, icon: Icon(Icons.delete_sweep)),
                ],
              ),

              cartModel.cartLoaded && cartModel.productsLoaded
                  ? cartModel.products.isEmpty
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsetsGeometry.symmetric(
                                vertical: 80,
                              ),
                              child: Center(
                                child: Text(
                                  "Добавьте товары в корзину",
                                  style: TextStyle(fontSize: 35),
                                ),
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: EdgeInsetsGeometry.all(10),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                int index,
                              ) {
                                return InCartProductCard(
                                  productId: cartModel.products[index].id,
                                  cartItemId: cartModel.cartItems[index].id,
                                );
                              }, childCount: cartModel.products.length),
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
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/cart.dart';
import 'classes.dart';

// Страница оплаты заказа

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, this.product = null, this.quantity = null});

  final Product? product;
  final int? quantity;

  @override
  State<StatefulWidget> createState() {
    return _PaymentPageState();
  }
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Color.fromARGB(255, 170, 230, 170),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.only(
                    // bottomLeft: Radius.circular(25),
                    // bottomRight: Radius.circular(25),
                  ),
                ),
                pinned: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: Text('Оплата заказа', style: TextStyle(fontSize: 20)),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  // выбор адреса доставки
                  Container(
                    padding: EdgeInsetsGeometry.all(10),
                    child: Text(
                      "Адрес доставки",
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => print('Кнопка 1'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0, // Убирает тень
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: EdgeInsetsGeometry.all(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.navigation_rounded),
                        SizedBox(width: 10),
                        Text('Выбрать адрес', style: TextStyle(fontSize: 20)),
                        Spacer(),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),

                  // способ оплаты
                  Container(
                    padding: EdgeInsetsGeometry.all(10),
                    child: Text(
                      "Способ оплаты",
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  // горизонтальный список с вариантами оплаты
                  Container(
                    padding: EdgeInsetsGeometry.all(10),

                    child: SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,

                        children: [
                          AspectRatio(
                            aspectRatio: 1.5,
                            child: GestureDetector(
                              onTap: () {},
                              child: Card(
                                elevation: 3,
                                margin: EdgeInsetsGeometry.all(10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.credit_card, size: 50),
                                    Text(
                                      "Карта",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          AspectRatio(
                            aspectRatio: 1.5,
                            child: GestureDetector(
                              onTap: () {},
                              child: Card(
                                elevation: 3,
                                margin: EdgeInsetsGeometry.all(10),

                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(Icons.payments, size: 50),
                                    Text("СБП", style: TextStyle(fontSize: 20)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          AspectRatio(
                            aspectRatio: 1.4,
                            child: GestureDetector(
                              onTap: () {},
                              child: Card(
                                elevation: 3,
                                margin: EdgeInsetsGeometry.all(10),

                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(Icons.money_rounded, size: 50),
                                    Text("Наличными", style: TextStyle(fontSize: 20)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
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
                padding: EdgeInsetsGeometry.only(
                  left: 5,
                  right: 5,
                  top: 5,
                  bottom: 20,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (cartModel.cartItems.isNotEmpty) {
                      // Navigator.pushNamed(context, '/checkout');
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
                      Text("Оплатить", style: TextStyle(fontSize: 20)),
                      Text(
                        " (${widget.quantity ?? cartModel.cartItems.length})",
                        style: TextStyle(fontSize: 20),
                      ),
                      Expanded(child: Spacer()),
                      Text(
                        "${widget.product != null ? widget.product!.price * widget.quantity! : cartModel.totalPrice.toStringAsFixed(2)} ₽",
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
    );
  }
}

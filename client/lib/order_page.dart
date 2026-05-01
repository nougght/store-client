import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/cart.dart';
import 'models/auth.dart';
import 'models/orders.dart';
import 'models/product.dart';
import 'cards.dart';
import 'map_page.dart';
import 'dart:async';
import 'classes.dart';
import 'package:step_progress/step_progress.dart';

// Страница оплаты заказа

Future<List<OrderItem>> cartToOrderItems(
  List<CartItem> items,
  ProductProvider provider,
  String orderId,
  BuildContext context
) async {
  List<OrderItem> result = [];
  for (var item in items) {
    Product? product = await provider.getProductById(item.productId, context);
    if (product == null) {
      debugPrint('Продукт из заказа не найден: ${item.productId}');
      continue;
    }
    result.add(
      OrderItem(
        orderId: orderId,
        productId: item.productId,
        quantity: item.quantity,
        price: product.price,
      ),
    );
  }
  return result;
}

class OrderPage extends StatefulWidget {
  const OrderPage({super.key, required this.order});

  final Order order;
  // final int? quantity;
  @override
  State<StatefulWidget> createState() {
    return _OrderPageState();
  }
}

class _OrderPageState extends State<OrderPage> {
  final nodeIcons = [
    Icon(Icons.watch_later_outlined, size: 40),
    Icon(Icons.directions_car_filled_outlined, size: 40),
    Icon(Icons.door_front_door_outlined, size: 40),
    Icon(Icons.done_outline_rounded, size: 40),
  ];
  List<Product?> products = [];
  Timer? timer;
  int step = 0;
  final titles = ["Обрабатываестя", "В пути", "Доставлен", "Завершен"];
  final progressController = StepProgressController(totalSteps: 4, initialStep: 0);
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 1000), (t) {
      if (progressController.currentStep >= step) {
        t.cancel();
        return;
      }
      setState(() {
        progressController.nextStep();
      });
    });
    var provider = context.read<ProductProvider>();
    Future.microtask(() async {
      if (mounted)
        setState(() {
          isLoading = true;
        });
      products = await provider.getProductsByIds(
        widget.order.items.map((e) {
          return e.productId;
        }).toList(), context
      );
      if (mounted)
        setState(() {
          isLoading = false;
        });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderModel>();
    final productProvider = Provider.of<ProductProvider>(context, listen: true);
    Timer? timer;
    step = widget.order?.status.index ?? 0;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            SizedBox(height: 40),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Spacer(),
              ],
            ),
            Text(
              'Заказ ${widget.order?.createdAt.toLocal().toString().substring(0, 16)}',
              style: TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
            ),
            StepProgress(
              totalSteps: 4,
              stepSize: 65,

              controller: progressController,

              // nodeTitles: ['Обрабатывается', 'В пути', 'Доставлен', 'Завершен'],
              padding: EdgeInsets.all(15),
              nodeIconBuilder: (index, completedStepIndex) => nodeIcons[index],
              // autoStartProgress: true,
              theme: StepProgressThemeData(
                activeForegroundColor: const Color.fromARGB(255, 94, 232, 145),
                shape: StepNodeShape.circle,
                nodeLabelAlignment: StepLabelAlignment.bottom,
                stepLineSpacing: 37,
                stepLineStyle: StepLineStyle(lineThickness: 10, borderRadius: Radius.circular(10)),
                // nodeLabelStyle: StepLabelStyle(
                //   activeColor: Colo
                // )
                // stepNodeStyle: StepNodeStyle(
                //   decoration: BoxDecoration()
                // ),
              ),
            ),
            Text(
              titles[progressController.currentStep],
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
              textAlign: TextAlign.center,
            ),

            Text(
              "Адрес: ${widget.order.delivery.address}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 10),
            Text(
              "Товары",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
              textAlign: TextAlign.left,
            ),

            Flexible(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: BoxBorder.all(
                          color: const Color.fromARGB(255, 143, 198, 140),
                          width: 2,
                        ),
                      ),
                      padding: EdgeInsets.only(right: 5),
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.only(left: 5, right: 5),
                          itemBuilder: (context, i) {
                            if (products[i] != null) {
                              return InOrderProductCard(
                                product: products[i]!,
                                orderItem: widget.order.items[i],
                              );
                            }
                          },
                          itemCount: widget.order.items.length,
                        ),
                      ),
                    ),
            ),
            Text(
              "Итого:",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
              textAlign: TextAlign.left,
            ),
            Row(
              children: [
                Text(
                  "Товары",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
                  textAlign: TextAlign.left,
                ),
                Spacer(),
                Text(
                  "${widget.order.totalPrice - widget.order.deliveryPrice}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
                  textAlign: TextAlign.left,
                ),
              ],
            ),

            Row(
              children: [
                Text(
                  "Доставка",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
                  textAlign: TextAlign.left,
                ),
                Spacer(),
                Text(
                  "${widget.order.deliveryPrice}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

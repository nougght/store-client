import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_store/payment_page.dart';
import 'package:provider/provider.dart';
import 'models/cart.dart';
import 'models/orders.dart';
import 'models/product.dart';
import 'classes.dart';
import 'models/auth.dart';
import 'cards.dart';

class MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  MySliverPersistentHeaderDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(color: Colors.white, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(MySliverPersistentHeaderDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _OrdersPageState();
  }
}

class _OrdersPageState extends State<OrdersPage> {
  bool ordersLoaded = false;
  List<List<String>> activeOrdersImgs = [];
  List<List<String>> completedOrdersImgs = [];

  List<Order> activeOrders = [];
  List<Order> completedOrders = [];
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    ordersLoaded = false;
    final orderModel = context.read<OrderModel>();
    await orderModel.fetchOrders();

    activeOrders = orderModel.currentOrders;
    completedOrders = orderModel.completedOrders;

    List<List<String>> activeImgs = [];
    List<List<String>> completedImgs = [];
    List<Future<List<String>>> imageFutures = [];

    for (int i = 0; i < activeOrders.length; i++) {
      activeImgs.add([]);
      for (int j = 0; j < activeOrders[i].items.length; j++) {
        var product = await context.read<ProductProvider>().getProductById(
          activeOrders[i].items[j].productId,
          context
        );
        if (product != null) {
          imageFutures.add(product.getImages(context));
        }
      }
    }
    await Future.wait(imageFutures);

    // int c = 0;
    for (int i = 0; i < activeOrders.length; i++) {
      for (int j = 0; j < activeOrders[i].items.length; j++) {
        var product = await context.read<ProductProvider>().getProductById(
          activeOrders[i].items[j].productId, context
        );
        if (product != null) {
          activeImgs[i].add(product.images.isEmpty ? "" : product.images[0]);
        }
        // imgs[i].add(images[c].isEmpty ? "" : images[c][0]);
        // c++;
      }
    }
    setState(() => this.activeOrdersImgs = activeImgs);


    imageFutures = [];

    for (int i = 0; i < completedOrders.length; i++) {
      completedImgs.add([]);
      for (int j = 0; j < completedOrders[i].items.length; j++) {
        var product = await context.read<ProductProvider>().getProductById(
          completedOrders[i].items[j].productId, context
        );
        if (product != null) {
          imageFutures.add(product.getImages(context));
        }
      }
    }
    await Future.wait(imageFutures);

    // int c = 0;
    for (int i = 0; i < completedOrders.length; i++) {
      for (int j = 0; j < completedOrders[i].items.length; j++) {
        var product = await context.read<ProductProvider>().getProductById(
          completedOrders[i].items[j].productId, context
        );
        if (product != null) {
          completedImgs[i].add(product.images.isEmpty ? "" : product.images[0]);
        }
        // imgs[i].add(images[c].isEmpty ? "" : images[c][0]);
        // c++;
      }
    }
    setState(() => this.completedOrdersImgs = completedImgs);

    ordersLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final orderModel = Provider.of<OrderModel>(context);
    if (ordersLoaded && orderModel.orders.length != activeOrdersImgs.length + completedOrdersImgs.length) {
      _loadOrders();
    }
    return Consumer<OrderModel>(
      builder: (context, orderModel, child) {
        return Scaffold(
          body: DefaultTabController(
            length: 2,
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    backgroundColor: Color.fromARGB(255, 170, 230, 170),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                    pinned: true,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    title: Text(
                      "Заказы",
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      // IconButton(

                      // ),
                    ],
                    //collapsedHeight: 100,
                  ),
                  SliverPersistentHeader(
                    delegate: MySliverPersistentHeaderDelegate(
                      TabBar(
                        tabs: [
                          Tab(text: "Активные"),
                          Tab(text: "Завершенные"),
                        ],
                      ),
                    ),
                    pinned: false,
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  activeOrders.isNotEmpty
                      ? ListView.builder(
                          itemBuilder: (context, index) {
                            return OrderCard(order: activeOrders[index], images: activeOrdersImgs[index]);
                          },
                          itemCount: activeOrders.length,
                        )
                      : Center(
                          child: Text(
                            'Активных заказов нет',
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                        ),
                  completedOrders.isNotEmpty
                      ? ListView.builder(
                          itemBuilder: (context, index) {
                            return OrderCard(order: completedOrders[index], images: completedOrdersImgs[index]);
                          },
                          itemCount: completedOrders.length,
                        )
                      : Center(
                          child: Text(
                            'Завершенных заказов нет',
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

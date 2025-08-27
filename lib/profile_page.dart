import 'package:flutter/material.dart';
import 'package:mobile_store/favourites_page.dart';
import 'package:mobile_store/models/product.dart';
import 'package:mobile_store/settings_page.dart';
import 'package:provider/provider.dart';
import 'models/auth.dart';
import 'classes.dart';
import 'models/orders.dart';
import 'orders_page.dart';
import 'cards.dart';
import 'order_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // List<dynamic> data = [];
  bool ordersLoaded = false;
  List<List<String>> imgs = [];

  @override
  initState() {
    super.initState();
    Future.microtask(() async {
      await _loadOrders(context);
    });
  }

  var _isAppBarExpanded = false;
  late ScrollController _scrollController = ScrollController()
    ..addListener(() {
      setState(() {
        _isAppBarExpanded = _scrollController.hasClients && _scrollController.offset > 20;
      });
    });

  Future<void> _loadOrders(BuildContext context) async {
    ordersLoaded = false;
    final orderModel = context.read<OrderModel>();
    await orderModel.fetchOrders();

    List<List<String>> activeImgs = [];
    List<Future<List<String>>> imageFutures = [];

    for (int i = 0; i < orderModel.currentOrders.length; i++) {
      activeImgs.add([]);
      for (int j = 0; j < orderModel.currentOrders[i].items.length; j++) {
        var product = await context.read<ProductProvider>().getProductById(
          orderModel.currentOrders[i].items[j].productId,
          context,
        );
        if (product != null) {
          imageFutures.add(product.getImages(context));
        }
      }
    }
    await Future.wait(imageFutures);

    // int c = 0;
    for (int i = 0; i < orderModel.currentOrders.length; i++) {
      for (int j = 0; j < orderModel.currentOrders[i].items.length; j++) {
        var product = await context.read<ProductProvider>().getProductById(
          orderModel.currentOrders[i].items[j].productId, context
        );
        if (product != null) {
          activeImgs[i].add(product.images.isEmpty ? "" : product.images[0]);
        }
        // imgs[i].add(images[c].isEmpty ? "" : images[c][0]);
        // c++;
      }
    }
    setState(() => this.imgs = activeImgs);
    ordersLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context);
    final orderModel = Provider.of<OrderModel>(context);
    if (ordersLoaded && orderModel.currentOrders.length != imgs.length) {
      _loadOrders(context);
    }
    final productProvider = Provider.of<ProductProvider>(context);
    return RefreshIndicator(
      onRefresh: () => _loadOrders(context),
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  backgroundColor: Color.fromARGB(255, 170, 230, 170),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  pinned: true,
                  snap: true,
                  floating: true,
                  expandedHeight: 90,

                  leading: Icon(Icons.person_rounded),
                  title: Text(
                    authModel.currentUser!.username,
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),

                  flexibleSpace: _isAppBarExpanded
                      ? null
                      : FlexibleSpaceBar(
                          centerTitle: true,
                          // background: Container(color: Colors.blueGrey),
                          title: Container(
                            // color: Colors.amber,
                            margin: EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: const Color.fromARGB(50, 76, 76, 76),
                                  width: 1,
                                ),
                              ),
                            ),
                            padding: EdgeInsetsGeometry.only(left: 10, right: 10, top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Почта: ${authModel.currentUser!.email}',
                                  style: TextStyle(fontSize: 10),
                                ),
                                Text(
                                  'Телефон: ${authModel.currentUser!.phone != '' ? authModel.currentUser!.phone : '--'}',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                  actions: [
                    // IconButton(

                    // ),
                  ],
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    if (ordersLoaded && orderModel.orders.isNotEmpty)
                      SizedBox(
                        height: orderModel.currentOrders.isNotEmpty ? 200 : 50,
                        child: orderModel.currentOrders.isNotEmpty
                            ? ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return OrderCard(
                                    order: orderModel.currentOrders[index],
                                    images: imgs[index],
                                  );
                                },
                                itemCount: orderModel.currentOrders.length > 4
                                    ? 4
                                    : orderModel.currentOrders.length,
                              )
                            : Center(
                                child: Text(
                                  'Активных заказов нет',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: const Color.fromARGB(255, 107, 107, 106),
                                  ),
                                ),
                              ),
                      ),

                    Center(
                      child: IntrinsicWidth(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => OrdersPage()),
                            );
                          },

                          style: ElevatedButton.styleFrom(
                            // elevation: 0, // Убирает тень
                            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            backgroundColor: Color.fromARGB(255, 170, 230, 170),
                            padding: EdgeInsetsGeometry.all(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.list_alt_rounded),
                              SizedBox(width: 10),
                              Text('Все заказы', style: TextStyle(fontSize: 20)),
                              // Spacer(),
                              // Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => FavouritesPage()),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.bookmark_rounded),
                          SizedBox(width: 10),
                          Text('Избранное', style: TextStyle(fontSize: 20)),
                          Spacer(),
                          Icon(Icons.chevron_right),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0, // Убирает тень
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: EdgeInsetsGeometry.all(10),
                      ),
                    ),
                    Divider(height: 1),
                    ElevatedButton(
                      onPressed: () {},
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => OrderPage())),
                      child: Row(
                        children: [
                          Icon(Icons.history),
                          SizedBox(width: 10),
                          Text('История', style: TextStyle(fontSize: 20)),
                          Spacer(),
                          Icon(Icons.chevron_right),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0, // Убирает тень
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: EdgeInsetsGeometry.all(10),
                      ),
                    ),
                    Divider(height: 1),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SettingsPage()),
                      ),

                      style: ElevatedButton.styleFrom(
                        elevation: 0, // Убирает тень
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: EdgeInsetsGeometry.all(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.settings),
                          SizedBox(width: 10),
                          Text('Настройки', style: TextStyle(fontSize: 20)),
                          Spacer(),
                          Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    Divider(height: 1),
                    SizedBox(height: 20),

                    Center(
                      child: IntrinsicWidth(
                        child: TextButton(
                          onPressed: () => authModel.logout(),
                          style: TextButton.styleFrom(
                            elevation: 0, // Убирает тень
                            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            padding: EdgeInsetsGeometry.all(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, color: Colors.red),
                              SizedBox(width: 10),
                              Text(
                                'Выйти из аккаунта',
                                style: TextStyle(fontSize: 20, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Placeholder(fallbackHeight: 500),
                  ]),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((_, index) => Placeholder(), childCount: 0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

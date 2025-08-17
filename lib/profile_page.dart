import 'package:flutter/material.dart';
import 'package:mobile_store/favourites_page.dart';
import 'package:mobile_store/models/product.dart';
import 'package:mobile_store/settings_page.dart';
import 'package:provider/provider.dart';
import 'models/auth.dart';
import 'classes.dart';
import 'models/orders.dart';
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
    _loadOrders();
  }

  var _isAppBarExpanded = false;
  late ScrollController _scrollController = ScrollController()
    ..addListener(() {
      setState(() {
        _isAppBarExpanded = _scrollController.hasClients && _scrollController.offset > 20;
      });
    });

  Future<void> _loadOrders() async {
    ordersLoaded = false;
    final orderModel = context.read<OrderModel>();
    await orderModel.fetchOrders();

    List<List<String>> imgs = [];
      for (int i = 0; i < orderModel.orders.length; i++) {
        imgs.add([]);
        for (int j = 0; j < orderModel.orders[i].items.length; j++) {
          var product = context.read<ProductProvider>().getProductById(
            orderModel.orders[i].items[j].productId,
          );
          if (product != null) {
            imgs[i].add((await (product as Product).getImages())[0]);
          }
        }
      }
    setState(() => this.imgs = imgs,);
    ordersLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context);
    final orderModel = Provider.of<OrderModel>(context);
    if (orderModel.orders.length != imgs.length) {
      _loadOrders();
    }
    final productProvider = Provider.of<ProductProvider>(context);
    return Scaffold(
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
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          OrderCard(order: orderModel.orders[index], images: imgs[index]);
                        },
                        itemCount: orderModel.orders.length > 4 ? 4 : orderModel.orders.length,
                      ),
                    ),
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
                      onPressed: () =>
                          Navigator.push(context, MaterialPageRoute(builder: (_) => OrderPage())),
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
                      child: ElevatedButton(
                        onPressed: () => authModel.logout(),
                        style: ElevatedButton.styleFrom(
                          elevation: 0, // Убирает тень
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                  ]),
                ),
              SliverList(
                delegate: SliverChildBuilderDelegate((_, index) => Placeholder(), childCount: 0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

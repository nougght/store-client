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
import 'package:yandex_maps_mapkit/init.dart' as init;

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
  bool isInit = false;
  int page = 1;
  int limit = 20;
  late final ScrollController _scrollController;
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    Future.microtask(() async {
      await _initYandexMaps();
    });

    Future.microtask(() async {
      await _loadProducts(1, 20, context);
      isInit = true;
    });
  }

  void _onScroll() async {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoading) {
      await _loadProducts(++page, limit, context, append: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initYandexMaps() async {
    try {
      String key = await widget.api.getYandexMapKey();
      await init.initMapkit(apiKey: key, locale: 'ru_RU');
      print("Yandex Maps initialized");
    } catch (e) {
      print("Error initializing Yandex Maps: $e");
    }
  }

  Future<void> _loadProducts(
    int page,
    int limit,
    BuildContext context, {
    bool append = false,
  }) async {
    // _products = await widget.api.fetchProducts();
    final provider = context.read<ProductProvider>();
    if (isLoading) return;
    setState(() => isLoading = true);
    await provider.fetchList(
      key: "home",
      filters: {"sort": "created_desc"},
      page: page,
      limit: limit,
      append: append,
      context: context,
    ); // первая загрузка

    setState(() => isLoading = false);
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (isInit) {
          products = provider.getList("home");
        } else {
          return Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () {
            page = 1;
            return _loadProducts(page, limit, context);
          },
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
                          return ProductCard(product: products[i]);
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 7,
                          crossAxisSpacing: 4,
                          childAspectRatio: 0.6,
                        ),
                        itemCount: products.length,
                      ),
                    ),
                    if (isLoading)
                      SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

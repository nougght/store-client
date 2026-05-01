// lib/main.dart
import 'package:admin_panel/pages/category_page.dart';
import 'package:admin_panel/pages/images_page.dart';
import 'package:admin_panel/pages/product_page.dart';
import 'package:admin_panel/pages/orders_page.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'pages/login_page.dart';
import 'pages/category_page.dart';
import 'pages/page.dart';
// import 'pages/products_page.dart';
// import 'pages/images_page.dart';
// import 'pages/categories_page.dart';
// import 'pages/orders_page.dart';
// import 'pages/delivery_page.dart';
import 'widgets/side_menu.dart';
import 'api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'models/product.dart';
import 'models/category.dart';
import 'models/order.dart';

void main() {
  final apiService = ApiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider(apiService: apiService)),
        ChangeNotifierProvider(create: (_) => CategoryModel(apiService)),
        ChangeNotifierProvider(create: (_) => OrderModel(apiService)),
      ],

      child: AdminApp(apiService: apiService),
    ),
  );
}

class AdminApp extends StatefulWidget {
  final ApiService apiService;

  const AdminApp({Key? key, required this.apiService}) : super(key: key);
  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  bool _loggedIn = true;
  String _selectedPage = 'Товары';

  final Map<String, Widget> _pages = {
    // 'Статистика': Page1(),
    'Товары': ProductsPage(),
    'Изображения товаров': Page1(),
    'Категории': Page1(),
    'Заказы': OrdersPage(),
    // 'Доставка': Page1(),
  };

  void _login(String password) {
    // TODO: заменить на реальную проверку через API
    if (password == 'admin123') {
      setState(() => _loggedIn = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Неверный пароль')));
    }
  }

  @override
  Widget build(BuildContext context) {
    _pages['Изображения товаров'] = ImagesPage(api: widget.apiService);
    _pages['Категории'] = CategoriesPage(api: widget.apiService);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, widget) => ResponsiveBreakpoints.builder(
        child: ClampingScrollWrapper.builder(context, widget!),

        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: 'XL'),
        ],
      ),
      home: _loggedIn
          ? LayoutBuilder(
              builder: (context, constraints) {
                bool isDesktop = constraints.maxWidth >= 1024;
                return Scaffold(
                  appBar: isDesktop
                      ? null
                      : AppBar(
                          title: Text(_selectedPage),
                          leading: Builder(
                            builder: (context) => IconButton(
                              icon: Icon(Icons.menu),
                              onPressed: () => Scaffold.of(context).openDrawer(),
                            ),
                          ),
                        ),
                  drawer: isDesktop
                      ? null
                      : Drawer(
                          child: SideMenu(
                            selectedPage: _selectedPage,
                            onSelect: (name) {
                              setState(() => _selectedPage = name);
                              Navigator.pop(context); // закрыть меню
                            },
                          ),
                        ),
                  body: Row(
                    children: [
                      if (isDesktop)
                        SideMenu(
                          selectedPage: _selectedPage,
                          onSelect: (name) {
                            setState(() => _selectedPage = name);
                          },
                        ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          child: _pages[_selectedPage]!,
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          : LoginPage(onLogin: _login),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mobile_store/services/api_service.dart';
import 'classes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'models/cart.dart';

import 'cards.dart';
import 'shopping_cart.dart';
import 'main_page.dart';
import 'profile_page.dart';
import 'auth.dart';
import 'models/auth.dart';
import 'models/orders.dart';
import 'models/product.dart';

import 'catalog_page.dart';
import 'models/catalog.dart';
import 'models/settings.dart';
// import 'package:yandex_maps_mapkit_lite/init.dart' as init;
import 'package:yandex_maps_mapkit/init.dart' as init;
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  final userId = prefs.getString('userId') ?? '';
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  // сейчас ключ загружается с сервера
  // await dotenv.load(fileName: ".env");
  // final akey = dotenv.env['YANDEX_MAPKIT_KEY'] ?? '';
  // await init.initMapkit(apiKey: akey, locale: 'ru_RU');
  
  
  // CachedNetworkImage. = cacheManager;

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
        ChangeNotifierProvider(
          create: (context) => ProductProvider(apiService: context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              SettingsModel(context.read<ApiService>(), token == '' ? false : isDarkMode),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              CatalogModel(context.read<ApiService>(), context.read<ProductProvider>()),
        ),
        ChangeNotifierProvider(create: (context) => CartModel(context.read<ApiService>(), context.read<ProductProvider>())),
        ChangeNotifierProvider(
          create: (context) => AuthModel(context.read<ApiService>())..autoLogin(token, userId),
        ),
        ChangeNotifierProvider(
          create: (context) => OrderModel(context.read<ApiService>(), context.read<AuthModel>()),
        ),
      ],
      child: const TestApp(),
    ),
  ); 
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});


  @override
  Widget build(BuildContext context) {
    final settingsModel = Provider.of<SettingsModel>(context);

    return MaterialApp(
      title: 'Test',
      debugShowCheckedModeBanner: false,
      theme: settingsModel.currentTheme,

      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;
  late List<Widget> pages;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    
    pages = <Widget>[
      MainPage(api: context.read<ApiService>()),
      CatalogPage(), CartPage(), ProfilePage(),
    ];


  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthModel>();
    if (user.isAuth && context.read<CartModel>().cartId == null) {
      context.read<CartModel>().setCartIdByUserId(user.currentUser!.userId, context);
    }
    
    return user.isSplashScreen
        ? Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlutterLogo(size: 100),
                  const SizedBox(height: 50),
                  const CircularProgressIndicator(
                    semanticsLabel: 'Loading...',
                    color: Color.fromARGB(248, 133, 231, 166),
                    strokeWidth: 5,
                  ),
                ],
              ),
            ),
          )
        : user.isAuth
        ? Scaffold(
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                // border: Border(top: BorderSide(color: const Color.fromARGB(50, 76, 76, 76))),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(17, 0, 0, 0),
                    blurRadius: 1,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: NavigationBar(
                // поменять цвет
                // backgroundColor: Theme.of(context).colorScheme.inverseSurface.withAlpha(20),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                selectedIndex: _selectedIndex,
                destinations: <Widget>[
                  NavigationDestination(icon: Icon(Icons.home), label: "Главная"),
                  NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: "Каталог"),
                  NavigationDestination(icon: Icon(Icons.shopping_cart), label: "Корзина"),
                  NavigationDestination(icon: Icon(Icons.account_circle_rounded), label: "Профиль"),
                ],

                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
            body: IndexedStack(index: _selectedIndex, children: pages),
          )
        : AuthPage();
  }
}

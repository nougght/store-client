import 'package:flutter/material.dart';
import 'package:mobile_store/services/api_service.dart';
import 'classes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'models/cart.dart';

import 'cards.dart';
import 'shopping_cart.dart';
import 'main_page.dart';
import 'profile_page.dart';
import 'auth.dart';
import 'models/user.dart';
import 'catalog_page.dart';
import 'models/catalog.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
        ChangeNotifierProvider(
          create: (context) => UserModel(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => CatalogModel(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => CartModel(context.read<ApiService>()),
        ),
      ],
      child: const TestApp(),
    ),
  ); // запуск приложения
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(249, 75, 226, 125),
        ),
      ),
      home: MainScreen(),
    );
  }
}
// const CatalogPage(
//         categories: {
//           "Электроника": "electronic.png",
//           "Книги": "books.png",
//           "Продукты питания": "food.png",
//           "Одежда": "clothes.png",
//           "Аксессуары": "accessories.png",
//           "Распродажа": "sale.png",
//         },
//       )

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
      // Scaffold(
      //   // appBar: AppBar(
      //   //   backgroundColor: Color.fromARGB(248, 133, 231, 166),
      //   //   title: Text("Тест", style: TextStyle(fontSize: 20)),
      //   // ),
      // ),
      CatalogPage(), CartPage(), ProfilePage(),
      // Scaffold(
      //   appBar: AppBar(
      //     backgroundColor: Color.fromARGB(248, 133, 231, 166),
      //     title: Text("Корзина", style: TextStyle(fontSize: 20)),
      //   ),
      // ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserModel>();
    return user.isAuth
        ? Scaffold(
            bottomNavigationBar: NavigationBar(
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              selectedIndex: _selectedIndex,
              destinations: <Widget>[
                NavigationDestination(icon: Icon(Icons.home), label: "Главная"),
                NavigationDestination(
                  icon: Icon(Icons.grid_view_rounded),
                  label: "Каталог",
                ),
                NavigationDestination(
                  icon: Icon(Icons.shopping_cart),
                  label: "Корзина",
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_circle_rounded),
                  label: "Профиль",
                ),
              ],

              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
            body: IndexedStack(index: _selectedIndex, children: pages),
          )
        : AuthPage();
  }
}

class MainPage1 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainPageState1();
}

class _MainPageState1 extends State<MainPage1> {
  List<dynamic> data = [];
  // List<Product> products = [
  //   Product(
  //     id: 0,
  //     name: "Хлеб",
  //     description: "Ржаной хлеб",
  //     price: 35.0,
  //     stock: 5,
  //     categoryId: 2,
  //   ),
  //   Product(
  //     id: 1,
  //     name: "Молоко",
  //     description: "1 литр, 3.2%",
  //     price: 70.0,
  //     stock: 10,
  //     categoryId: 2,
  //   ),
  //   Product(
  //     id: 2,
  //     name: "Смартфон",
  //     description: "Android, 128GB",
  //     price: 15999.0,
  //     stock: 3,
  //     categoryId: 0,
  //   ),
  //   Product(
  //     id: 3,
  //     name: "Книга",
  //     description: "Роман, 350 стр.",
  //     price: 450.0,
  //     stock: 7,
  //     categoryId: 1,
  //   ),
  //   Product(
  //     id: 4,
  //     name: "Футболка",
  //     description: "100% хлопок",
  //     price: 599.0,
  //     stock: 15,
  //     categoryId: 3,
  //   ),
  // ];
  Future<void> fetchData() async {
    final url = Uri.parse('http://10.0.2.2:8080/products');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          data = data.toList();
        });
        // print(data);
      } else {
        print('Ошибка: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка: $e');
    }
  }

  @override
  initState() {
    super.initState();
    fetchData();
  }

  Widget gridBuild(BuildContext c, int i) {
    return ProductCard(product: Product.fromJson(data[i]));
    // Placeholder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(248, 133, 231, 166),
        title: Text(
          "Главная",
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        // actions: [Icon(Icons.delete_sweep_rounded)],
      ),
      body: Container(
        child: data.isNotEmpty
            ? GridView.builder(
                padding: EdgeInsetsGeometry.all(15),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.55,
                ),
                itemCount: 140,
                itemBuilder: gridBuild,
              )
            : Center(
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
    );
  }
}

// TextField(
//             onSubmitted: (value) {
//               setState(() {
//                 _filter = value;
//                 fetchData();
//               });
//             },
//             onChanged: (value) {
//               setState(() {
//                 _filter = value;
//                 fetchData();
//               });
//             },
//             decoration: InputDecoration(
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               hintText: "Поиск",
//               prefixIcon: Icon(Icons.search),
//               contentPadding: EdgeInsetsGeometry.directional(),
//             ),
//           ),

// Widget CustomSearchField() {
//   dynamic onChangedHandler;
//   return TextField(
//     onSubmitted: (value) {
//       setState(() {
//         _filter = value;
// fetchData()
//       });
//     },
//     onChanged: (value) {
//       setState(() {
//         _filter = value;
//         fetchData();
//       });
//     },
//     decoration: InputDecoration(
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       hintText: "Поиск",
//       prefixIcon: Icon(Icons.search),
//       contentPadding: EdgeInsetsGeometry.directional(),
//     ),
//   );
// }

import 'package:flutter/material.dart';
import 'package:mobile_store/services/api_service.dart';
import 'classes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'models/cart.dart';

import 'cards.dart';
import 'shopping_cart.dart';
import 'main_page.dart';
import 'profile_page.dart';
import 'auth.dart';
import 'models/user.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
        ChangeNotifierProvider(
          create: (context) => CartModel(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => UserModel(context.read<ApiService>()),
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
class CategoryCard extends StatelessWidget {
  CategoryCard({super.key, required this.category, this.hasImage = false}) {
    {
      base64toPng(this.category.image);
    }
  }

  final Category category;
  late bool hasImage;
  late Image image;
  // final String name;
  // final String imagePath;

  bool isValidBase64(String str) {
    try {
      base64.decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  void base64toPng(String img) {
    String pureBase = img.split(',').last;
    if (!isValidBase64(img)) {
      while (pureBase.length % 4 != 0) {
        pureBase += "=";
      }
    }
    Uint8List bytes = base64Decode(pureBase);

    image = Image.memory(
      bytes,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Placeholder();
      },
    );
    hasImage = true;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        // Закругление
        borderRadius: BorderRadius.circular(12),
      ),
      color: Color.fromARGB(255, 219, 219, 219),

      child: Column(
        children: [
          Text(category.name, style: TextStyle(fontSize: 20)),
          Expanded(
            child: hasImage ? image : Icon(Icons.error),
            // child: imagePath == ""
            //     ? Placeholder()
            //     : Image.asset("assets/images/$imagePath"),
          ),
        ],
      ),
    );
  }
}

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  final Map categories = const {
    "Электроника": "electronic.png",
    "Книги": "books.png",
    "Продукты питания": "food.png",
    "Одежда": "clothes.png",
    "Аксессуары": "accessories.png",
    "Распродажа": "sale.png",
    "Спорт": "",
    "Обувь": "",
    "Мебель": "",
    "Зоотовары": "",
  };

  @override
  State<StatefulWidget> createState() => _CalalogPageState();
}

// 127.0.0.1
// 10.0.2.2 - эмулятор
class _CalalogPageState extends State<CatalogPage> {
  String _filter = "";
  List<dynamic> data = [];
  List<dynamic> filtered = [];

  Future<void> fetchData() async {
    final url = Uri.parse('https://26aef7d5e7a1.ngrok-free.app/categories');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          _filterCards();
        });
        // print(data);
      } else {
        print('Ошибка: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка: $e');
    }
  }

  void _filterCards() {
    setState(() {
      filtered = _filter == ""
          ? data
          : data.where((element) {
              return (element["name"].toLowerCase().indexOf(
                    _filter.toLowerCase(),
                  ) !=
                  -1);
            }).toList();
    });
    // for (int i = 0; i < widget.categories.values.length; i++) {
    //   if (_filter == "" ||
    //       widget.categories.keys
    //               .elementAt(i)
    //               .toLowerCase()
    //               .indexOf(_filter.toLowerCase()) !=
    //           -1) {
    //     res.add(
    //       CategoryCard(
    //         name: widget.categories.keys.elementAt(i),
    //         imagePath: widget.categories.values.elementAt(i),
    //       ),
    //     );
    //   }
    // }
    // return res;
    // return List.generate(
    //   widget.categories.values.length,
    //   (int index) {
    //     return widget.categories.keys.elementAt(index).indexOf(_filter) == -1 ? Null :
    //     CategoryCard(
    //       name: widget.categories.keys.elementAt(index),
    //       imagePath: widget.categories.values.elementAt(index),
    //     );
    //   },
    // );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(80),
      //   child: Material(
      //     color: Colors.transparent,
      //     child: Stack(
      //       children: [
      //         Positioned(
      //           child: Container(
      //             height: 115,
      //             alignment: Alignment.topCenter,
      //             decoration: BoxDecoration(
      //               color: Colors.green,
      //               borderRadius: BorderRadius.vertical(
      //                 bottom: Radius.circular(30),
      //               ),
      //             ),
      //             child: AppBar(
      //               backgroundColor: Color.fromARGB(0, 133, 231, 166),
      //               elevation: 0,
      //               title: Padding(
      //                 padding: EdgeInsetsGeometry.only(bottom: 0, top: 0),
      //                 child: TextField(
      //                   onSubmitted: (value) {
      //                     setState(() {
      //                       _filter = value;
      //                       fetchData();
      //                     });
      //                   },
      //                   onChanged: (value) {
      //                     setState(() {
      //                       _filter = value;
      //                       fetchData();
      //                     });
      //                   },
      //                   decoration: InputDecoration(
      //                     border: OutlineInputBorder(
      //                       borderRadius: BorderRadius.circular(10),
      //                     ),
      //                     hintText: "Поиск",
      //                     prefixIcon: Icon(Icons.search),
      //                     contentPadding: EdgeInsetsGeometry.directional(),
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      body: Stack(
        children: [
          CustomScrollView(
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
                title: Container(
                  padding: EdgeInsetsGeometry.all(5),
                  child: TextField(
                    onSubmitted: (value) {
                      setState(() {
                        _filter = value;
                        _filterCards();
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        _filter = value;
                        _filterCards();
                      });
                    },
                    maxLines: 1,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: "Поиск",
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsetsGeometry.directional(),
                    ),
                  ),
                ),
              ),
              data.isNotEmpty
                  ? SliverPadding(
                      padding: EdgeInsetsGeometry.all(10),
                      sliver: SliverGrid.builder(
                        itemBuilder: (context, index) {
                          return CategoryCard(
                            category: Category.fromJson(filtered[index]),
                          );
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,

                          // childAspectRatio: 0.55,
                        ),
                        itemCount: filtered.length,
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
              //                Container(
              //   color: Colors.grey,
              //   // padding: EdgeInsetsGeometry.only(top: 115),
              //   child: Column(
              //     children: [
              //       Expanded(
              //         child: data.isNotEmpty
              //             ? GridView.count(
              //                 // physics: ClampingScrollPhysics(),
              //                 padding: EdgeInsetsGeometry.only(
              //                   top: 125,
              //                   bottom: 15,
              //                   left: 15,
              //                   right: 15,
              //                 ),
              //                 crossAxisCount: 2,
              //                 scrollDirection: Axis.vertical,
              //                 mainAxisSpacing: 10,
              //                 crossAxisSpacing: 10,

              //                 children: _filterCards(),
              //               )
              //             : Center(
              //                 child: Column(
              //                   spacing: 20,
              //                   mainAxisAlignment: MainAxisAlignment.center,
              //                   children: <Widget>[
              //                     Text("Загрузка...", style: TextStyle(fontSize: 30)),
              //                     CircularProgressIndicator(),
              //                   ],
              //                 ),
              //               ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

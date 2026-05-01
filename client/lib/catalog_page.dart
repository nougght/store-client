import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mobile_store/cards.dart';
import 'package:mobile_store/services/api_service.dart';
import 'package:mobile_store/models/product.dart';
import 'classes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:provider/provider.dart';

import 'models/catalog.dart';

class CategoryCard extends StatelessWidget {
  CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    required this.isSelected,
    this.hasImage = false,
  });

  //  {
  //   {
  //     base64toPng(this.category.image);
  //   }
  // }
  final VoidCallback onTap;
  final bool isSelected;
  final Category category;
  late bool hasImage;
  late Image image;
  // final String name;
  // final String imagePath;

  // bool isValidBase64(String str) {
  //   try {
  //     base64.decode(str);
  //     return true;
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     return false;
  //   }
  // }

  // void base64toPng(String img) {
  //   String pureBase = img.split(',').last;
  //   if (!isValidBase64(img)) {
  //     while (pureBase.length % 4 != 0) {
  //       pureBase += "=";
  //     }
  //   }
  //   Uint8List bytes = base64Decode(pureBase);

  //   image = Image.memory(
  //     bytes,
  //     fit: BoxFit.contain,
  //     errorBuilder: (context, error, stackTrace) {
  //       return const Placeholder();
  //     },
  //   );
  //   hasImage = true;
  // }

  @override
  Widget build(BuildContext context) {
    // final catalogModel = Provider.of<CatalogModel>(context, listen: true);
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          // Закругление
          borderRadius: BorderRadius.circular(12),
        ),
        color: isSelected ? Color.fromARGB(255, 230, 179, 90) : Color.fromARGB(255, 219, 219, 219),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(category.name, style: TextStyle(fontSize: 15), textAlign: TextAlign.center,),
            Expanded(
              child: hasImage ? image : Icon(Icons.error),
              // child: imagePath == ""
              //     ? Placeholder()
              //     : Image.asset("assets/images/$imagePath"),
            ),
          ],
        ),
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
  int _radioVal = 0;
  List<String> _radioText = ["Дешевле", "Дороже", "Новые"];

  // void _filterCards() {
  //   setState(() {
  //     filtered = _filter == ""
  //         ? data
  //         : data.where((element) {
  //             return (element["name"].toLowerCase().indexOf(
  //                   _filter.toLowerCase(),
  //                 ) !=
  //                 -1);
  //           }).toList();
  //   });
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
  // }
  bool isLoading = false;
  // int page = 1;
  // int limit = 20;
  late ScrollController _scrollController;
  // @override
  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies
  //   super.didChangeDependencies();

  // }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    Future.microtask(() async {
      await _loadCategories(append: false);
    });

    // _loadProducts(1, 20);
  }

  void _onScroll() async {
    final catalogModel = Provider.of<CatalogModel>(context, listen: false);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !isLoading) {
      setState(() => isLoading = true);
      await catalogModel.filteredProducts(context, append: true);
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Future<void> _loadProducts(int page, int limit) async {
  //   // _products = await widget.api.fetchProducts();
  //   if (isLoading) return;
  //   setState(() => isLoading = true);

  //   setState(() => isLoading = false);
  //   // setState(() {});
  // }

  Future<void> _loadCategories({bool append = false}) async {
    final catalogModel = context.read<CatalogModel>();
    await catalogModel.fetchCategories();
    await catalogModel.filteredProducts(context, append: append);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    return Consumer<CatalogModel>(
      builder: (context, catalogModel, child) {
        final products = provider.getList("catalog");
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () => catalogModel.fetchCategories(),
            // onRefresh: () => _loadCatalog(),
            child: Stack(
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
                      title: Container(
                        padding: EdgeInsetsGeometry.all(5),
                        child: TextField(
                          onSubmitted: (value) {},
                          onChanged: (value) {
                            catalogModel.setSearchQuery(value, context);
                          },
                          maxLines: 1,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            hintText: "Поиск",
                            prefixIcon: Icon(Icons.search),
                            contentPadding: EdgeInsetsGeometry.directional(),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsetsGeometry.all(10),
                      sliver: catalogModel.categoriesLoaded
                          ? SliverGrid.builder(
                              itemBuilder: (context, index) {
                                return CategoryCard(
                                  category: catalogModel.categories[index],
                                  isSelected:
                                      catalogModel.categories[index].id ==
                                      catalogModel.selectedCategoryId,
                                  onTap: () => catalogModel.setSelectedCategory(
                                    catalogModel.categories[index].id, context
                                  ),
                                );
                              },
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 5,
                                childAspectRatio: 1,
                              ),
                              itemCount: catalogModel.categories.length,
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
                    ),
                    SliverToBoxAdapter(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 7),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 1, color: Color.fromARGB(84, 0, 0, 0)),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadiusGeometry.only(
                                        topLeft: Radius.circular(25),
                                        topRight: Radius.circular(25),
                                      ),
                                    ),
                                    builder: (context) {
                                      return Consumer<CatalogModel>(
                                        builder: (context, model, child) {
                                          return IntrinsicHeight(
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadiusGeometry.all(
                                                  Radius.circular(
                                                    10,
                                                  ), // без радиуса контейнер выходит за границы bottomsheet
                                                ),
                                                // color: Theme.of(context).colorScheme.primary,
                                              ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "Показывать сначала",
                                                    style: TextStyle(fontSize: 25),
                                                  ),
                                                  SizedBox(height: 20),
                                                  ClipRRect(
                                                    borderRadius: BorderRadiusGeometry.all(
                                                      Radius.circular(20),
                                                    ),
                                                    child: Container(
                                                      padding: EdgeInsetsGeometry.symmetric(
                                                        vertical: 10,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(
                                                          context,
                                                        ).colorScheme.secondary.withAlpha(200),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          RadioListTile(
                                                            value: 0,
                                                            groupValue: catalogModel.selectedSort,
                                                            title: Text(
                                                              _radioText[0],
                                                              style: TextStyle(fontSize: 20),
                                                            ),
                                                            onChanged: (value) {
                                                              if (value != null) {
                                                                catalogModel.setSort(value, context);
                                                              }
                                                            },
                                                          ),
                                                          Divider(
                                                            indent: 20,
                                                            endIndent: 20,
                                                            color: Colors.black.withAlpha(100),
                                                          ),
                                                          RadioListTile(
                                                            value: 1,
                                                            groupValue: catalogModel.selectedSort,
                                                            title: Text(
                                                              _radioText[1],
                                                              style: TextStyle(fontSize: 20),
                                                            ),
                                                            onChanged: (value) {
                                                              if (value != null) {
                                                                catalogModel.setSort(value, context);
                                                              }
                                                            },
                                                          ),
                                                          Divider(
                                                            indent: 20,
                                                            endIndent: 20,
                                                            color: Colors.black.withAlpha(100),
                                                          ),
                                                          RadioListTile(
                                                            value: 2,
                                                            groupValue: catalogModel.selectedSort,
                                                            title: Text(
                                                              _radioText[2],
                                                              style: TextStyle(fontSize: 20),
                                                            ),
                                                            onChanged: (value) {
                                                              if (value != null) {
                                                                catalogModel.setSort(value, context);
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 20),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                // style: ElevatedButton.styleFrom(elevation: 0,
                                // backgroundColor: Theme.of(context).colorScheme.secondary),
                                child: Row(
                                  children: [
                                    Icon(Icons.sort_rounded),
                                    SizedBox(width: 10),
                                    Text('Сортировка', style: TextStyle(fontSize: 20)),
                                  ],
                                ),
                              ),

                              TextButton(
                                onPressed: () {},
                                // style: ElevatedButton.styleFrom(
                                //   backgroundColor: Theme.of(
                                //     context,
                                //   ).colorScheme.secondary,
                                // ),
                                child: Row(
                                  children: [
                                    Icon(Icons.settings),
                                    SizedBox(width: 10),
                                    Text('Фильтр', style: TextStyle(fontSize: 20)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsetsGeometry.all(10),
                      sliver: catalogModel.productsLoaded
                          ? SliverGrid.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 7,
                                crossAxisSpacing: 4,
                                childAspectRatio: 0.6,
                              ),
                              itemBuilder: (context, i) {
                                return ProductCard(product: products[i]);
                              },
                              itemCount: products.length,
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
          ),
        );
      },
    );
  }
}

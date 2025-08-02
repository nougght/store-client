import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mobile_store/cards.dart';
import 'package:mobile_store/services/api_service.dart';
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
  }) {
    {
      base64toPng(this.category.image);
    }
  }
  final VoidCallback onTap;
  final bool isSelected;
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
    // final catalogModel = Provider.of<CatalogModel>(context, listen: true);
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          // Закругление
          borderRadius: BorderRadius.circular(12),
        ),
        color: isSelected
            ? Color.fromARGB(255, 230, 179, 90)
            : Color.fromARGB(255, 219, 219, 219),

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

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    final catalogModel = Provider.of<CatalogModel>(context, listen: false);
    await catalogModel.fetchCategories();
    await catalogModel.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CatalogModel>(
      builder: (context, catalogModel, child) {
        return Scaffold(
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
                        onSubmitted: (value) {},
                        onChanged: (value) {
                          catalogModel.setSearchQuery(value);
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
                                  catalogModel.categories[index].id,
                                ),
                              );
                            },
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
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
                                  Text(
                                    "Загрузка...",
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  CircularProgressIndicator(),
                                ],
                              ),
                            ),
                          ),
                  ),
                  SliverPadding(
                    padding: EdgeInsetsGeometry.all(10),
                    sliver: catalogModel.productsLoaded
                        ? SliverGrid.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 0.55,
                                ),
                            itemBuilder: (context, i) {
                              return ProductCard(
                                product: catalogModel.filteredProducts[i],
                              );
                            },
                            itemCount: catalogModel.filteredProducts.length,
                          )
                        : SliverToBoxAdapter(
                            child: Center(
                              child: Column(
                                spacing: 20,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Загрузка...",
                                    style: TextStyle(fontSize: 30),
                                  ),
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
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

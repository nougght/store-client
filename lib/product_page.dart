import 'package:flutter/material.dart';
import 'classes.dart';

class ProductPage extends StatefulWidget {
  ProductPage({super.key, required this.product});
  Product product;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProductPageState();
  }
}

class _ProductPageState extends State<ProductPage> {
  late bool isInCart;
  late bool isInFavourite;
  @override
  void initState() {
    super.initState();
    isInCart = false;
    isInFavourite = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Color.fromARGB(207, 185, 185, 185),
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
                title: Placeholder(fallbackHeight: 40,),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.bookmark,
                      color: isInFavourite
                          ? Colors.amber
                          : const Color.fromARGB(255, 65, 65, 65),
                    ),
                  ),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  widget.product.images.isEmpty ? Placeholder() : Placeholder(),
                  Container(
                    color: Color.fromARGB(255, 206, 212, 211),
                    padding: EdgeInsetsGeometry.only(left: 5, right: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 5,
                      children: [
                        Text(
                          widget.product.price.toStringAsFixed(2),
                          style: TextStyle(fontSize: 35, height: 1),
                        ),
                        Text(
                          widget.product.name,
                          style: TextStyle(fontSize: 45, height: 1),
                        ),
                        Text(
                          "${widget.product.quantity} ${widget.product.unit}",
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.blueGrey,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                        ),
                        // padding: EdgeInsetsGeometry.only(left: 50, right: 50),
                        Padding(
                          padding: EdgeInsetsGeometry.only(
                            left: 150,
                            right: 150,
                            // top: 20,
                            // bottom: 20,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 147, 251, 157),
                              border: BoxBorder.all(
                                width: 2,
                                color: Color.fromARGB(255, 90, 129, 130),
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Icon(Icons.star),
                                Text("4.78", style: TextStyle(fontSize: 25)),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            // color: Color.fromARGB(255, 147, 251, 157),
                            border: BoxBorder.all(
                              width: 2,
                              color: Color.fromARGB(255, 90, 129, 130),
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children: [
                              Text("Описание", style: TextStyle(fontSize: 40)),
                              Text(
                                "......................................",
                                style: TextStyle(fontSize: 30),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            // color: Color.fromARGB(255, 147, 251, 157),
                            border: BoxBorder.all(
                              width: 2,
                              color: Color.fromARGB(255, 90, 129, 130),
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children: [
                              Text("Отзывы", style: TextStyle(fontSize: 40)),
                              Text(
                                "Один\nДва\nТри\nЧетыре\nПять\n6\n7\n8\n9\n0",
                                style: TextStyle(fontSize: 30),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right:0,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(207, 185, 185, 185),
                  // borderRadius: BorderRadius.only(
                  //   topLeft: Radius.circular(20),
                  //   topRight: Radius.circular(10),
                  // ),
                ),
                padding: EdgeInsetsGeometry.only(
                  left: 10,
                  right: 10,
                  top: 5,
                  bottom: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            160,
                            213,
                            159,
                          ),
                        ),
                        child: Text(
                          "Купить",
                          style: TextStyle(fontSize: 25, height: 2),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            159,
                            201,
                            213,
                          ),
                        ),
                        child: Text(
                          "В корзину",
                          style: TextStyle(fontSize: 25, height: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

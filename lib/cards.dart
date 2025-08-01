import 'package:flutter/material.dart';
import 'classes.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'product_page.dart';

import 'package:provider/provider.dart';
import 'models/cart.dart';
import 'package:http/http.dart' as http;

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.product, this.hasImage = false});

  final Product product;
  final bool hasImage;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool hasImage;
  late bool isInFavourite;
  late List<Image> images;
  int _imageIndex = 0;
  late bool isInCart;
  late int quantityInCart;

  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    hasImage = widget.hasImage;

    images = [
      // Container(height: 700, width: 700, color: Colors.blue),
      // Container(
      //   height: 1000,
      //   width: 700,
      //   color: const Color.fromARGB(255, 243, 33, 33),
      // ),
      // Container(
      //   height: 700,
      //   width: 1000,
      //   color: const Color.fromARGB(255, 33, 243, 47),
      // ),
      Image.asset("assets/images/1.jpg", fit: BoxFit.contain),
      Image.asset("assets/images/2.jpg", fit: BoxFit.contain),
      Image.asset("assets/images/3.jpg", fit: BoxFit.contain),
      Image.asset("assets/images/0.png", fit: BoxFit.contain),
    ];
    base64toPng(widget.product.images);

    // loadImage();
  }

  // final Product product;
  // late bool hasImage;
  // late List<Image> images;
  // late int _imageIndex;
  // final String name;
  // final String imagePath;

  void loadImage() {
    for (int i = 0; i < 4; i++) {
      final ImageStream stream = AssetImage(
        'assets/images/$i.jpg',
      ).resolve(ImageConfiguration.empty);
      stream.addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          debugPrint(
            "Real image size: ${info.image.width} x ${info.image.height}\n",
          );
        }),
      );
    }
  }

  bool isValidBase64(String str) {
    try {
      base64.decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  void base64toPng(List<String> img) {
    for (var i = 0; i < img.length; i++) {
      String pureBase = img[i].split(',').last;
      if (!isValidBase64(img[i])) {
        while (pureBase.length % 4 != 0) {
          pureBase += "=";
        }
      }
      Uint8List bytes = base64Decode(pureBase);

      // images[i] = Image.memory(
      //   bytes,
      //   fit: BoxFit.contain,
      //   errorBuilder: (context, error, stackTrace) {
      //     return const Placeholder();
      //   },
      // );
    }

    hasImage = true;
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);

    isInFavourite = false;
    isInCart = cartModel.isProductInCart(widget.product.id);
    
    quantityInCart = isInCart
        ? cartModel.getProductQuantity(widget.product.id)
        : 0;
    
    textController = TextEditingController(
      text: isInCart ? quantityInCart.toString() : "1",
    );
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductPage(product: widget.product),
          ),
        );
      },
      child: Card(
        elevation: 1, // Тень
        shape: RoundedRectangleBorder(
          // Закругление
          borderRadius: BorderRadius.circular(12),
        ),
        color: Color.fromARGB(255, 216, 231, 221),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // пробовал sizedbox + layoutbuilder, не получилось сделать квадрат
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  PageView.builder(
                    padEnds: false,
                    onPageChanged: (value) {
                      setState(() {
                        _imageIndex = value;
                      });
                    },
                    itemCount: images.length,
                    itemBuilder: (context, index) => ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: Container(
                        margin: EdgeInsetsGeometry.all(0),
                        padding: EdgeInsetsGeometry.all(0),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(48, 31, 31, 31),
                          // borderRadius: BorderRadius.all(
                          //   Radius.circular(0),
                          // ),
                          // border: BoxBorder.all(width: 1)
                        ),
                        child: images[index],
                      ),
                    ),
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 5,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(120, 100, 100, 100),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (index) {
                              return IntrinsicWidth(
                                child: Container(
                                  width: index == _imageIndex ? 8 : 4,
                                  height: index == _imageIndex ? 8 : 4,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 3,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: index == _imageIndex
                                        ? const Color.fromARGB(
                                            255,
                                            239,
                                            46,
                                            46,
                                          ).withValues(alpha: 0.5)
                                        : const Color.fromARGB(
                                            255,
                                            225,
                                            225,
                                            225,
                                          ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      // style: ButtonStyle(backgroundColor: WidgetStateColor.resolveWith(Colors.white)),
                      onPressed: () {
                        setState(() {
                          isInFavourite = !isInFavourite;
                        });
                      },
                      icon: isInFavourite
                          ? Icon(Icons.bookmark_rounded, color: Colors.amber)
                          : Icon(
                              Icons.bookmark_outline_rounded,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsetsGeometry.only(left: 5, right: 5, top: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.product.price.toStringAsFixed(2) + ' ₽',
                      style: TextStyle(fontSize: 25),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      widget.product.name,
                      style: TextStyle(fontSize: 17, height: 1),
                      textAlign: TextAlign.left,
                      maxLines: 2,
                    ),
                    Text(
                      "${widget.product.quantity} ${widget.product.unit}",
                      style: TextStyle(fontSize: 15, color: Colors.blueGrey),
                      textAlign: TextAlign.left,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsetsGeometry.only(left: 5, right: 5, bottom: 5),
              child: !Provider.of<CartModel>(context).cartLoaded ||
                      !isInCart
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsetsGeometry.all(0),
                      ),
                      onPressed: () async {
                        await Provider.of<CartModel>(
                          context,
                          listen: false,
                        ).addToCart(widget.product);

                        // Provider.of<CartModel>(
                        //   context,
                        //   listen: false,
                        // ).fetchCartItems();
                        setState(() {
                          isInCart = true;
                          quantityInCart++;
                          textController.text = quantityInCart.toString();

                          // for (var i = 0; i < 3; i++) {
                          //   debugPrint(
                          //     '${images[i].width} * ${images[i].height}\n',
                          //   );
                          // }
                        });
                      },
                      child: Text("В корзину"),
                    )
                  : Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            
                            if (quantityInCart <= 1) {
                              isInCart = false;
                              if (await context.read<CartModel>().deleteFromCart(
                                widget.product,
                              )) {
                                setState(() {
                                  quantityInCart = 0;
                                  textController.text = "1";
                                  isInCart = false;
                                });
                              }
                            } else {
                              if (await context.read<CartModel>().updateCartItemQuantity(
                                widget.product,
                                quantityInCart,
                              )) {
                                setState(() {
                                  quantityInCart--;
                                  textController.text = quantityInCart.toString();
                                });

                              }
                            }
                          },
                          icon: Icon(Icons.remove),
                        ),
                        Expanded(
                          child: TextField(
                            controller: textController,
                            style: TextStyle(fontSize: 15),
                            decoration: InputDecoration(isDense: true),
                            onSubmitted: (value) {
                              int newQuantity = int.tryParse(value) ?? 1;
                              if (newQuantity < 1) {
                                newQuantity = 1;
                              }
                              setState(() {
                                quantityInCart = newQuantity;
                                textController.text = quantityInCart.toString();
                              });
                              context.read<CartModel>().updateCartItemQuantity(
                                widget.product,
                                newQuantity,
                              );
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            if (await context
                                .read<CartModel>()
                                .updateCartItemQuantity(
                                  widget.product,
                                  quantityInCart + 1,
                                )) {
                              setState(() {
                                quantityInCart++;
                                textController.text = quantityInCart.toString();
                              });
                            }
                          },
                          icon: Icon(Icons.add),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class InCartProductCard extends StatefulWidget {
  // добавить cartItem
  InCartProductCard({
    super.key,
    required this.productId,
    this.hasImage = false,
    required this.cartItemId,
  });
  final String productId;
  final String cartItemId;
  final bool hasImage;

  @override
  State<InCartProductCard> createState() => _InCartProductCardState();
}

class _InCartProductCardState extends State<InCartProductCard> {
  late TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    final CartModel cartModel = Provider.of<CartModel>(context);
    final product = cartModel.getProductById(widget.productId);
    final cartItem = cartModel.getCartItemById(widget.cartItemId);
    textController  = TextEditingController(
      text: cartItem.quantity.toString(),
    );

    // TODO: implement build
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductPage(product: product),
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraits) {
          return Card(
            elevation: 2,
            // color: Colors.lightBlue, // Тень
            shape: RoundedRectangleBorder(
              // Закругление
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.all(5),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          margin: EdgeInsetsGeometry.only(right: 5),
                          child: SizedBox(
                            width: constraits.maxWidth / 2.5,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                child: Container(
                                  margin: EdgeInsetsGeometry.all(0),
                                  padding: EdgeInsetsGeometry.only(),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(48, 31, 31, 31),
                                    // borderRadius: BorderRadius.all(
                                    //   Radius.circular(0),
                                    // ),
                                    // border: BoxBorder.all(width: 1)
                                  ),
                                  child: Image.asset('assets/images/food.png'),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: constraits.maxWidth / 2.5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text("${product.price.toStringAsFixed(2)} ₽",
                                        style: TextStyle(
                                          fontSize: 30,
                                          // backgroundColor: Colors.amber,
                                        ),
                                        maxLines: 1,
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        product.name,
                                        style: TextStyle(fontSize: 20),
                                        textAlign: TextAlign.left,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        "${product.quantity} ${product.unit}",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.blueGrey,
                                        ),
                                        textAlign: TextAlign.left,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                IntrinsicHeight(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    spacing: 5,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                  255,
                                                  160,
                                                  213,
                                                  159,
                                                ),
                                          ),
                                          child: Text(
                                            "Купить",
                                            style: TextStyle(
                                              fontSize: 15,
                                              height: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.cyanAccent,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(999),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                padding: EdgeInsets.all(5),
                                                constraints: BoxConstraints(),
                                                onPressed: () {
                                                  setState(() {
                                                    cartItem.quantity--;
                                                    textController.text = cartItem
                                                        .quantity
                                                        .toString();
                                                    if (cartItem
                                                            .quantity <=
                                                        0) {
                                                      context
                                                          .read<CartModel>()
                                                          .deleteFromCart(
                                                            product,
                                                          );
                                                    } else {
                                                      context
                                                          .read<CartModel>()
                                                          .updateCartItemQuantity(
                                                            product,
                                                            cartItem
                                                                .quantity,
                                                          );
                                                    }
                                                  });
                                                },
                                                icon: Icon(Icons.remove),
                                                iconSize: 15,
                                              ),
                                              Expanded(
                                                child: TextField(
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                  controller: textController,
                                                  onSubmitted: (value) {
                                                    int newQuantity =
                                                        int.tryParse(value) ??
                                                        1;
                                                    if (newQuantity < 1) {
                                                      newQuantity = 1;
                                                    }
                                                    setState(() {
                                                      cartItem.quantity =
                                                          newQuantity;
                                                      textController.text =
                                                          newQuantity
                                                              .toString();
                                                    });
                                                    context
                                                        .read<CartModel>()
                                                        .updateCartItemQuantity(
                                                          product,
                                                          newQuantity,
                                                        );
                                                  },
                                                ),
                                              ),
                                              IconButton(
                                                padding: EdgeInsets.all(5),
                                                constraints: BoxConstraints(),
                                                onPressed: () {
                                                  setState(() {
                                                    cartItem.quantity++;
                                                    textController.text = cartItem
                                                        .quantity
                                                        .toString();
                                                  });
                                                  context
                                                      .read<CartModel>()
                                                      .updateCartItemQuantity(
                                                        product,
                                                        cartItem
                                                            .quantity,
                                                      );
                                                },
                                                icon: Icon(Icons.add),
                                                iconSize: 15,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: Checkbox(
                    value: cartItem.isChecked,
                    onChanged: (checkState) {
                      setState(() {
                        cartItem.isChecked = checkState ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

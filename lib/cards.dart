import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'classes.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'product_page.dart';

import 'package:provider/provider.dart';
import 'models/cart.dart';
import 'models/auth.dart';
import 'package:http/http.dart' as http;

class ProductCard extends StatefulWidget {
  ProductCard({super.key, required this.product});

  final Product product;
  late bool hasImage = true;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool isInFavourite;
  late List<Image> images;
  int _imageIndex = 0;
  late bool isInCart;
  late int quantityInCart;
  late bool isImagesLoaded = false;

  late TextEditingController textController;

  @override
  void initState() {
    super.initState();

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
    isImagesLoaded = true;

    // base64toPng(widget.product.images);

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
          debugPrint("Real image size: ${info.image.width} x ${info.image.height}\n");
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

    // isImagesLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);
    final authModel = Provider.of<AuthModel>(context);

    isInFavourite = authModel.isProductInFavourites(widget.product.id);

    isInCart = cartModel.isProductInCart(widget.product.id);

    quantityInCart = isInCart ? cartModel.getProductQuantity(widget.product.id) : 0;

    textController = TextEditingController(text: isInCart ? quantityInCart.toString() : "1");

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductPage(product: widget.product)),
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
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: PageView.builder(
                      padEnds: false,
                      onPageChanged: (value) {
                        setState(() {
                          _imageIndex = value;
                        });
                      },
                      itemCount: widget.hasImage ? images.length : 1,
                      itemBuilder: (context, index) => Container(
                        margin: EdgeInsetsGeometry.all(0),
                        padding: EdgeInsetsGeometry.all(0),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(48, 31, 31, 31),
                          // borderRadius: BorderRadius.all(
                          //   Radius.circular(0),
                          // ),
                          // border: BoxBorder.all(width: 1)
                        ),
                        child: widget.hasImage
                            ? isImagesLoaded
                                  ? images[index]
                                  : Center(child: CircularProgressIndicator())
                            : Placeholder(),
                      ),
                    ),
                  ),
                  if (widget.hasImage && images.length > 1)
                    Positioned(
                      bottom: 5,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(120, 100, 100, 100),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(1.5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (index) {
                              return IntrinsicWidth(
                                child: Container(
                                  width: index == _imageIndex ? 8 : 4,
                                  height: index == _imageIndex ? 8 : 4,
                                  margin: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: index == _imageIndex
                                        ? const Color.fromARGB(201, 235, 48, 48)
                                        : const Color.fromARGB(201, 225, 225, 225),
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
                      onPressed: () async {
                        if (isInFavourite) {
                          if (await authModel.deleteFromFavourites(widget.product.id)) {
                            setState(() {
                              isInFavourite = false;
                            });
                          }
                        } else if (await authModel.addToFavourites(
                          widget.product.id,
                        )) {
                          setState(() {
                            isInFavourite = true;
                          });
                        }
                        ;
                      },
                      icon: isInFavourite
                          ? Icon(Icons.bookmark_rounded, color: Colors.amber)
                          : Icon(Icons.bookmark_outline_rounded, color: Colors.grey),
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
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      widget.product.name,
                      style: TextStyle(fontSize: 17, height: 1),
                      textAlign: TextAlign.left,
                      maxLines: 1,
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
            AspectRatio(
              aspectRatio: 3.5,
              child: Container(
                // color: Colors.amber,
                padding: EdgeInsetsGeometry.only(left: 5, right: 5, bottom: 5),
                margin: EdgeInsets.all(0),
                child: !Provider.of<CartModel>(context).cartLoaded || !isInCart
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsetsGeometry.all(0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                        child: Text("В корзину", style: TextStyle(fontSize: 22)),
                      )
                    : Card(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(99),
                        ),
                        margin: EdgeInsets.all(0),
                        child: Padding(
                          padding: EdgeInsetsGeometry.all(3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                padding: EdgeInsets.all(7),
                                constraints: BoxConstraints(),
                                style: IconButton.styleFrom(
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
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
                                      quantityInCart - 1,
                                    )) {
                                      setState(() {
                                        quantityInCart--;
                                        textController.text = quantityInCart.toString();
                                      });
                                    }
                                  }
                                },
                                icon: Icon(Icons.remove),
                                iconSize: 25,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: textController,
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.center,
                                  style: TextStyle(fontSize: 20, height: 1),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    // border: OutlineInputBorder(),
                                    // contentPadding: EdgeInsets.all(0),
                                  ),
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
                                padding: EdgeInsets.all(7),
                                constraints: BoxConstraints(),
                                style: IconButton.styleFrom(
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () async {
                                  if (await context.read<CartModel>().updateCartItemQuantity(
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
                                iconSize: 25,
                              ),
                            ],
                          ),
                        ),
                      ),
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
    textController = TextEditingController(text: cartItem.quantity.toString());

    // TODO: implement build
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductPage(product: product)));
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
                            width: constraits.maxWidth / 3,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
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
                            height: constraits.maxWidth / 3,
                            // padding: EdgeInsets.all(0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        "${product.price.toStringAsFixed(2)} ₽",
                                        style: TextStyle(
                                          fontSize: 30,
                                          // backgroundColor: Colors.amber,
                                        ),
                                        maxLines: 1,
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        product.name,
                                        style: TextStyle(fontSize: 20, height: 1),
                                        textAlign: TextAlign.left,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        "${product.quantity} ${product.unit}",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.blueGrey,
                                          // height: 1
                                        ),
                                        textAlign: TextAlign.left,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 40,
                                  // color: Colors.amber,
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      spacing: 2,

                                      children: [
                                        ElevatedButton(
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
                                            style: TextStyle(fontSize: 18, height: 1),
                                          ),
                                        ),
                                        Expanded(
                                          child: Card(
                                            color: Theme.of(context).colorScheme.secondary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadiusGeometry.circular(99),
                                            ),
                                            margin: EdgeInsets.all(0),
                                            child: Padding(
                                              padding: EdgeInsetsGeometry.all(3),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                // spacing: 3,
                                                children: [
                                                  IconButton(
                                                    padding: EdgeInsets.all(8),
                                                    constraints: BoxConstraints(),
                                                    style: IconButton.styleFrom(
                                                      tapTargetSize:
                                                          MaterialTapTargetSize.shrinkWrap,
                                                      backgroundColor: const Color.fromARGB(
                                                        255,
                                                        255,
                                                        255,
                                                        255,
                                                      ).withAlpha(150),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        cartItem.quantity--;
                                                        textController.text = cartItem.quantity
                                                            .toString();
                                                        if (cartItem.quantity <= 0) {
                                                          context.read<CartModel>().deleteFromCart(
                                                            product,
                                                          );
                                                        } else {
                                                          context
                                                              .read<CartModel>()
                                                              .updateCartItemQuantity(
                                                                product,
                                                                cartItem.quantity,
                                                              );
                                                        }
                                                      });
                                                    },
                                                    icon: Icon(Icons.remove),
                                                    iconSize: 16,
                                                  ),
                                                  IntrinsicWidth(
                                                    child: TextField(
                                                      keyboardType:
                                                          TextInputType.numberWithOptions(),
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter.digitsOnly,
                                                      ],
                                                      decoration: InputDecoration(
                                                        fillColor: Color.fromARGB(
                                                          255,
                                                          255,
                                                          255,
                                                          255,
                                                        ).withAlpha(100),
                                                        filled: true,
                                                        focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            width: 2,
                                                            color: const Color.fromARGB(
                                                              255,
                                                              32,
                                                              32,
                                                              32,
                                                            ).withAlpha(150),
                                                          ),
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            width: 2,
                                                            color: const Color.fromARGB(
                                                              197,
                                                              111,
                                                              111,
                                                              111,
                                                            ).withAlpha(150),
                                                          ),
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),

                                                        counterText: "",
                                                        contentPadding: EdgeInsets.only(
                                                          left: 10,
                                                          right: 7,
                                                        ),
                                                        // isDense: true,
                                                      ),

                                                      maxLines: 1,
                                                      maxLength: 2,
                                                      style: TextStyle(fontSize: 18, height: 1),
                                                      textAlign: TextAlign.center,
                                                      textAlignVertical: TextAlignVertical.center,
                                                      controller: textController,
                                                      onSubmitted: (value) {
                                                        int newQuantity = int.tryParse(value) ?? 1;
                                                        if (newQuantity < 1) {
                                                          newQuantity = 1;
                                                        }
                                                        setState(() {
                                                          cartItem.quantity = newQuantity;
                                                          textController.text = newQuantity
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
                                                    padding: EdgeInsets.all(8),
                                                    constraints: BoxConstraints(),
                                                    style: IconButton.styleFrom(
                                                      tapTargetSize:
                                                          MaterialTapTargetSize.shrinkWrap,
                                                      backgroundColor: const Color.fromARGB(
                                                        255,
                                                        255,
                                                        255,
                                                        255,
                                                      ).withAlpha(150),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        cartItem.quantity++;
                                                        textController.text = cartItem.quantity
                                                            .toString();
                                                      });
                                                      context
                                                          .read<CartModel>()
                                                          .updateCartItemQuantity(
                                                            product,
                                                            cartItem.quantity,
                                                          );
                                                    },
                                                    icon: Icon(Icons.add),
                                                    iconSize: 16,
                                                  ),
                                                ],
                                              ),
                                            ),
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

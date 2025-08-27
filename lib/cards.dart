import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mobile_store/models/orders.dart';
import 'classes.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';

import 'product_page.dart';
import 'order_page.dart';
import 'models/cacheManager.dart';

import 'package:provider/provider.dart';
import 'models/cart.dart';
import 'models/auth.dart';
import 'package:mobile_store/models/product.dart';
import 'package:http/http.dart' as http;

class OrderCard extends StatelessWidget {
  OrderCard({super.key, required this.order, required this.images});

  final Order order;

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.push(context, MaterialPageRoute(builder: (_) => OrderPage(order: order)));
      },
      child: Card(
        elevation: 1, // Тень
        shape: RoundedRectangleBorder(
          // Закругление
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(10),
        color: Color.fromARGB(255, 216, 231, 221),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: AspectRatio(
            aspectRatio: 2,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Заказ ${order.createdAt}", style: TextStyle(fontSize: 14)),
                            Spacer(),
                          ],
                        ),

                        Text(OrderStatusToString(order.status), style: TextStyle(fontSize: 14)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("${order.totalPrice} ₽", style: TextStyle(fontSize: 12)),
                            Spacer(),
                            Text(order.delivery.address, style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: ListView.builder(
                      // padEnds: false,
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      // controller: PageController(viewportFraction: 0.2),
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 5, vertical: 5),
                        child: GestureDetector(
                          onTap: () async {
                            Product? product = await context.read<ProductProvider>().getProductById(
                              order.items[index].productId,
                              context,
                            );
                            if (product == null) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ProductPage(product: product)),
                            );
                          },
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              child: Container(
                                margin: EdgeInsetsGeometry.all(0),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(48, 31, 31, 31),
                                  // borderRadius: BorderRadius.all(
                                  //   Radius.circular(0),
                                  // ),
                                  // border: BoxBorder.all(width: 1)
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: images[index],
                                  // maxAge: const Duration(days: 7), // Очищать кэш через 7 дней
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Placeholder(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  ProductCard({super.key, required this.product});

  final Product product;
  // late bool hasImage = true;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool isInFavourite;
  // late List<CachedNetworkImage> images;
  int _imageIndex = 0;
  late bool isInCart;
  late int quantityInCart;
  late bool isImagesLoaded = false;
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();

    // images = [];

    // Image.asset("assets/images/1.jpg", fit: BoxFit.contain),
    // Image.asset("assets/images/2.jpg", fit: BoxFit.contain),
    // Image.asset("assets/images/3.jpg", fit: BoxFit.contain),
    // Image.asset("assets/images/0.png", fit: BoxFit.contain),
    // ];
    isInFavourite = false;
    isInCart = false;
    quantityInCart = 0;
    textController = TextEditingController(text: "1");

    // Future.microtask(() async {
    //   product = await context.read<ProductProvider>().getProductById(widget.productId) ?? Product();
    //   await _loadImages(product);
    //   isImagesLoaded = true;
    // });

    // base64toPng(widget.product.images);

    // loadImage();
  }

  // Future<void> _loadImages(Product product) async {
  //   try {
  //     List<String> urls = await product.getImages();

  //     if (mounted) {
  //       if (urls.isNotEmpty) {
  //         bool isInCache = await DefaultCacheManager().getFileFromCache(urls[0]) != null;
  //         debugPrint(isInCache.toString());
  //       }
  //       setState(() {
  //         images = List.generate(
  //           urls.length,
  //           (index) => CachedNetworkImage(
  //             key: ValueKey(urls[index]),
  //             imageUrl: urls[index],
  //             fit: BoxFit.contain,
  //             placeholder: (context, url) => CircularProgressIndicator(),
  //             errorWidget: (context, url, error) => Icon(Icons.error),
  //             fadeInDuration: Duration.zero,
  //             placeholderFadeInDuration: Duration.zero,
  //             fadeOutDuration: Duration.zero,
  //             cacheManager: MyCacheManager(),
  //           ),
  //         );
  //       });
  //     }
  //     debugPrint(images.length.toString());
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  // final Product product;
  // late bool hasImage;
  // late List<Image> images;
  // late int _imageIndex;
  // final String name;
  // final String imagePath;

  // void loadImage() {
  //   for (int i = 0; i < 4; i++) {
  //     final ImageStream stream = AssetImage(
  //       'assets/images/$i.jpg',
  //     ).resolve(ImageConfiguration.empty);
  //     stream.addListener(
  //       ImageStreamListener((ImageInfo info, bool _) {
  //         debugPrint("Real image size: ${info.image.width} x ${info.image.height}\n");
  //       }),
  //     );
  //   }
  // }

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
      child: widget.product.id == ""
          ? Center(child: CircularProgressIndicator())
          : Card(
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
                            itemCount: widget.product.hasImage ? widget.product.images.length : 1,
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
                              child: widget.product.hasImage
                                  ? widget.product.images.isEmpty
                                        ? Center(child: CircularProgressIndicator())
                                        : CachedNetworkImage(
                                            key: ValueKey(widget.product.images[index]),
                                            imageUrl: widget.product.images[index],
                                            fit: BoxFit.contain,
                                            placeholder: (context, url) =>
                                                CircularProgressIndicator(),
                                            errorWidget: (context, url, error) => Icon(Icons.error),
                                            fadeInDuration: Duration.zero,
                                            placeholderFadeInDuration: Duration.zero,
                                            fadeOutDuration: Duration.zero,
                                            cacheManager: MyCacheManager(),
                                          )
                                  : Placeholder(),
                            ),
                          ),
                        ),
                        if (widget.product.hasImage && widget.product.images.length > 1)
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
                                  children: List.generate(widget.product.images.length, (index) {
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
                              } else if (await authModel.addToFavourites(widget.product.id)) {
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
                                ).addToCart(widget.product, context);

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
                                            context,
                                          )) {
                                            setState(() {
                                              quantityInCart = 0;
                                              textController.text = "1";
                                              isInCart = false;
                                            });
                                          }
                                        } else {
                                          if (await context
                                              .read<CartModel>()
                                              .updateCartItemQuantity(
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
    required this.product,
    // this.hasImage = false,
    required this.cartItemId,
  });
  final Product product;
  final String cartItemId;
  // final bool hasImage;

  @override
  State<InCartProductCard> createState() => _InCartProductCardState();
}

class _InCartProductCardState extends State<InCartProductCard> {
  late TextEditingController textController;

  // Future<void> _loadImages(Product product) async {
  //   try {
  //     if (product == null) return;
  //     List<String> urls = await product.getImages();
  //     setState(() {
  //       image = CachedNetworkImage(
  //         key: ValueKey(urls[0]),
  //         imageUrl: urls[0],
  //         fit: BoxFit.contain,
  //         placeholder: (context, url) => CircularProgressIndicator(),
  //         errorWidget: (context, url, error) => Icon(Icons.error),
  //         fadeInDuration: Duration.zero,
  //         placeholderFadeInDuration: Duration.zero,
  //         fadeOutDuration: Duration.zero,
  //         cacheManager: MyCacheManager(),
  //       );
  //       // if (image) {
  //       //   // widget.hasImage = false;
  //       // }
  //     });
  //     // debugPrint(image.length.toString());
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  @override
  void initState() {
    super.initState();
    final ProductProvider productProvider = context.read<ProductProvider>();

    // Future.microtask(() async {
    //   product = await productProvider.getProductById(widget.productId) ?? Product();
    //   await _loadImages(product);
    // });
  }

  @override
  Widget build(BuildContext context) {
    final CartModel cartModel = Provider.of<CartModel>(context);
    final ProductProvider productProvider = Provider.of<ProductProvider>(context);
    final cartItem = cartModel.getCartItemById(widget.cartItemId);
    textController = TextEditingController(text: cartItem.quantity.toString());

    // TODO: implement build
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductPage(product: widget.product)),
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
                                  child: widget.product.hasImage
                                      ? widget.product.images.isEmpty
                                            ? CircularProgressIndicator()
                                            : CachedNetworkImage(
                                                key: ValueKey(widget.product.images[0]),
                                                imageUrl: widget.product.images[0],
                                                fit: BoxFit.contain,
                                                placeholder: (context, url) =>
                                                    CircularProgressIndicator(),
                                                errorWidget: (context, url, error) =>
                                                    Icon(Icons.error),
                                                fadeInDuration: Duration.zero,
                                                placeholderFadeInDuration: Duration.zero,
                                                fadeOutDuration: Duration.zero,
                                                cacheManager: MyCacheManager(),
                                              )
                                      : Placeholder(),
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
                                        "${widget.product.price.toStringAsFixed(2)} ₽",
                                        style: TextStyle(
                                          fontSize: 30,
                                          // backgroundColor: Colors.amber,
                                        ),
                                        maxLines: 1,
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        widget.product.name,
                                        style: TextStyle(fontSize: 20, height: 1),
                                        textAlign: TextAlign.left,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        "${widget.product.quantity} ${widget.product.unit}",
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
                                                            widget.product,
                                                            context,
                                                          );
                                                        } else {
                                                          context
                                                              .read<CartModel>()
                                                              .updateCartItemQuantity(
                                                                widget.product,
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
                                                              widget.product,
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
                                                            widget.product,
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

class InOrderProductCard extends StatefulWidget {
  // добавить cartItem
  InOrderProductCard({
    super.key,
    required this.product,
    // this.hasImage = false,
    required this.orderItem,
  });
  final Product product;
  final OrderItem orderItem;
  // final bool hasImage;

  @override
  State<InOrderProductCard> createState() => _InOrderProductCardState();
}

class _InOrderProductCardState extends State<InOrderProductCard> {
  @override
  Widget build(BuildContext context) {
    final CartModel cartModel = Provider.of<CartModel>(context);

    // TODO: implement build
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductPage(product: widget.product)),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraits) {
          return Card(
            elevation: 2,
            color: const Color.fromARGB(255, 130, 189, 216), // Тень
            shape: RoundedRectangleBorder(
              // Закругление
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.all(4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: [
                      Container(
                        margin: EdgeInsetsGeometry.only(right: 5),
                        child: SizedBox(
                          height: constraits.maxWidth / 5,
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
                                child: widget.product.hasImage
                                    ? widget.product.images.isEmpty
                                          ? CircularProgressIndicator()
                                          : CachedNetworkImage(
                                              key: ValueKey(widget.product.images[0]),
                                              imageUrl: widget.product.images[0],
                                              fit: BoxFit.contain,
                                              placeholder: (context, url) =>
                                                  CircularProgressIndicator(),
                                              errorWidget: (context, url, error) =>
                                                  Icon(Icons.error),
                                              fadeInDuration: Duration.zero,
                                              placeholderFadeInDuration: Duration.zero,
                                              fadeOutDuration: Duration.zero,
                                              cacheManager: MyCacheManager(),
                                            )
                                    : Placeholder(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: constraits.maxWidth / 5,
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
                                    Row(
                                      children: [
                                        Text(
                                          "${widget.product.price.toStringAsFixed(2)} ₽",
                                          style: TextStyle(
                                            fontSize: 20,
                                            // backgroundColor: Colors.amber,
                                          ),
                                          maxLines: 1,
                                        ),
                                        Spacer(),
                                        Text(
                                          "x${widget.orderItem.quantity} ",
                                          style: TextStyle(fontSize: 20),
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      widget.product.name,
                                      style: TextStyle(fontSize: 15, height: 1),
                                      textAlign: TextAlign.left,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      "${widget.product.quantity} ${widget.product.unit}",
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
                            ],
                          ),
                        ),
                      ),
                    ],
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

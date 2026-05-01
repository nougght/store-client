import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'models/cacheManager.dart';
import 'package:flutter/services.dart';
import 'package:mobile_store/payment_page.dart';
import 'package:provider/provider.dart';
import 'models/cart.dart';
import 'classes.dart';
import 'models/auth.dart';

class ProductPage extends StatefulWidget {
  ProductPage({super.key, required this.product});
  final Product product;
  @override
  State<StatefulWidget> createState() {
    return _ProductPageState();
  }
}

class _ProductPageState extends State<ProductPage> {
  late bool isInCart;
  late bool isInFavourite;
  // late List<Image> images;
  late int quantityInCart;
  late bool isImagesLoaded = false;
  int _imageIndex = 0;

  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    // images = [];
    // images = [
    //   // Container(height: 700, width: 700, color: Colors.blue),
    //   // Container(
    //   //   height: 1000,
    //   //   width: 700,
    //   //   color: const Color.fromARGB(255, 243, 33, 33),
    //   // ),
    //   // Container(
    //   //   height: 700,
    //   //   width: 1000,
    //   //   color: const Color.fromARGB(255, 33, 243, 47),
    //   // ),
    // ];

    // isInFavourite = false;
    // _loadImages();
    // isImagesLoaded = true;

    // base64toPng(widget.product.images);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  // void _loadImages() async {
  //   try {
  //     List<String> urls = await widget.product.getImages();
  //     setState(() {
  //       images = List.generate(
  //         urls.length,
  //         (index) => 
  //         Image.network(
  //           urls[index],
  //           fit: BoxFit.contain,
  //           errorBuilder: (context, error, stackTrace) => const Placeholder(),
  //         ),
  //       );
  //       // if (images.isEmpty) {
  //       //   widget.hasImage = false;
  //       // }
  //     });
  //     debugPrint(images.length.toString());
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);
    final authModel = Provider.of<AuthModel>(context);
    isInFavourite = authModel.favourites.any((fav) => fav.productId == widget.product.id);
    isInCart = cartModel.isProductInCart(widget.product.id);

    quantityInCart = isInCart ? cartModel.getProductQuantity(widget.product.id) : 0;
    textController = TextEditingController(text: isInCart ? quantityInCart.toString() : "1");

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Color.fromARGB(208, 255, 255, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.only(
                    // bottomLeft: Radius.circular(25),
                    // bottomRight: Radius.circular(25),
                  ),
                ),
                pinned: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: Placeholder(fallbackHeight: 40),
                actions: [
                  IconButton(
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
                    },
                    icon: Icon(
                      Icons.bookmark,
                      color: isInFavourite ? Colors.amber : const Color.fromARGB(255, 65, 65, 65),
                    ),
                  ),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: [
                        PageView.builder(
                          padEnds: false,
                          controller: PageController(viewportFraction: 1),
                          onPageChanged: (value) {
                            setState(() {
                              _imageIndex = value;
                            });
                          },

                          itemCount: widget.product.hasImage ? widget.product.images.length : 1,
                          itemBuilder: (context, index) => Padding(
                            padding: EdgeInsetsGeometry.symmetric(horizontal: 5, vertical: 5),
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
                                child: widget.product.hasImage
                                    ? widget.product.images.isEmpty
                                          ? CircularProgressIndicator()
                                          : CachedNetworkImage(
                                              key: ValueKey(widget.product.images[index]),
                                              imageUrl: widget.product.images[index],
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
                        if (widget.product.hasImage && widget.product.images.length > 1)
                          Positioned(
                            bottom: 20,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(120, 100, 100, 100),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.all(3),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(widget.product.images.length, (index) {
                                    return IntrinsicWidth(
                                      child: Container(
                                        width: index == _imageIndex ? 10 : 5,
                                        height: index == _imageIndex ? 10 : 5,
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
                        // Positioned(
                        //   top: 5,
                        //   right: 5,
                        //   child: IconButton(
                        //     // style: ButtonStyle(backgroundColor: WidgetStateColor.resolveWith(Colors.white)),
                        //     onPressed: () {
                        //       setState(() {
                        //         isInFavourite = !isInFavourite;
                        //       });
                        //     },
                        //     icon: isInFavourite
                        //         ? Icon(
                        //             Icons.bookmark_rounded,
                        //             color: Colors.amber,
                        //           )
                        //         : Icon(
                        //             Icons.bookmark_outline_rounded,
                        //             color: Colors.grey,
                        //           ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  Container(
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
                        Text(widget.product.name, style: TextStyle(fontSize: 45, height: 1)),
                        Text(
                          "${widget.product.quantity} ${widget.product.unit}",
                          style: TextStyle(fontSize: 30, color: Colors.blueGrey),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                        ),
                        // padding: EdgeInsetsGeometry.only(left: 50, right: 50),
                        // Padding(
                        //   padding: EdgeInsetsGeometry.only(
                        //     left: 150,
                        //     right: 150,
                        //     // top: 20,
                        //     // bottom: 20,
                        //   ),
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       color: Color.fromARGB(255, 147, 251, 157),
                        //       border: BoxBorder.all(
                        //         width: 2,
                        //         color: Color.fromARGB(255, 90, 129, 130),
                        //       ),
                        //       borderRadius: BorderRadius.all(Radius.circular(10)),
                        //     ),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,

                        //       children: [
                        //         Icon(Icons.star),
                        //         Text("4.78", style: TextStyle(fontSize: 25)),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        if (widget.product.description != "") Container(
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
                        // if (1 == 0) Container(
                        //   decoration: BoxDecoration(
                        //     // color: Color.fromARGB(255, 147, 251, 157),
                        //     border: BoxBorder.all(
                        //       width: 2,
                        //       color: Color.fromARGB(255, 90, 129, 130),
                        //     ),
                        //     borderRadius: BorderRadius.all(Radius.circular(10)),
                        //   ),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     spacing: 10,
                        //     children: [
                        //       Text("Отзывы", style: TextStyle(fontSize: 40)),
                        //       Text(
                        //         "Один\nДва\nТри\nЧетыре\nПять\n6\n7\n8\n9\n0",
                        //         style: TextStyle(fontSize: 30),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        SizedBox(height: 100),
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
            right: 0,
            child: LayoutBuilder(
              builder: (context, constraints) => ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  height: constraints.maxWidth / 5,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(208, 208, 208, 208),
                    // borderRadius: BorderRadius.only(
                    //   topLeft: Radius.circular(20),
                    //   topRight: Radius.circular(10),
                    // ),
                  ),
                  padding: EdgeInsetsGeometry.only(left: 7, right: 7, top: 7, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 5,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return PaymentPage(
                                    product: widget.product,
                                    quantity: quantityInCart == 0 ? 1 : quantityInCart,
                                  );
                                },
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 160, 213, 159),
                          ),
                          child: Text("Купить", style: TextStyle(fontSize: 27, height: 2)),
                        ),
                      ),
                      Expanded(
                        child: !Provider.of<CartModel>(context).cartLoaded || !isInCart
                            ? ElevatedButton(
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.secondary,
                                ),
                                child: Text("В корзину", style: TextStyle(fontSize: 25, height: 2)),
                              )
                            : Card(
                                color: Theme.of(context).colorScheme.secondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(99),
                                ),
                                margin: EdgeInsets.all(0),
                                child: Padding(
                                  padding: EdgeInsetsGeometry.only(bottom: 5, top: 5),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          if (quantityInCart <= 1) {
                                            isInCart = false;
                                            if (await context.read<CartModel>().deleteFromCart(
                                              widget.product, context
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
                                      ),
                                      Expanded(
                                        child: IntrinsicWidth(
                                          child: TextField(
                                            keyboardType: TextInputType.numberWithOptions(),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                            ],
                                            decoration: InputDecoration(
                                              //   fillColor: Color.fromARGB(
                                              //     255,
                                              //     255,
                                              //     255,
                                              //     255,
                                              //   ).withAlpha(100),
                                              //   filled: true,
                                              //   focusedBorder: OutlineInputBorder(
                                              //     borderSide: BorderSide(
                                              //       width: 2,
                                              //       color: const Color.fromARGB(
                                              //         255,
                                              //         32,
                                              //         32,
                                              //         32,
                                              //       ).withAlpha(150),
                                              //     ),
                                              //     borderRadius: BorderRadius.circular(10),
                                              //   ),
                                              //   enabledBorder: OutlineInputBorder(
                                              //     borderSide: BorderSide(
                                              //       width: 2,
                                              //       color: const Color.fromARGB(
                                              //         197,
                                              //         111,
                                              //         111,
                                              //         111,
                                              //       ).withAlpha(150),
                                              //     ),
                                              //     borderRadius: BorderRadius.circular(10),
                                              //   ),
                                              counterText: "",
                                              // contentPadding: EdgeInsets.only(left: 10, right: 7,),
                                              // isDense: true,
                                            ),

                                            maxLines: 1,
                                            maxLength: 2,
                                            style: TextStyle(fontSize: 27, height: 1),
                                            textAlign: TextAlign.center,
                                            textAlignVertical: TextAlignVertical.center,
                                            controller: textController,
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
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

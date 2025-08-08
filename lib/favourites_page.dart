import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_store/payment_page.dart';
import 'package:provider/provider.dart';
import 'models/cart.dart';
import 'classes.dart';
import 'models/auth.dart';
import 'cards.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _FavouritesPageState();
  }
}

class _FavouritesPageState extends State<FavouritesPage> {
  List<Product> _favourites = [];
  bool favouritesLoaded = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _loadFavourites();
  }

  Future<void> _loadFavourites() async {
    final authModel = Provider.of<AuthModel>(context, listen: true);
    if (authModel.isAuth == false) return;
    if (!authModel.favouritesLoaded) {
      await authModel.fetchFavourites();
      if (authModel.favouritesLoaded && authModel.favourites.isNotEmpty) {
        _favourites = await authModel.fetchProductsFromFavourites();
        setState(() {});
      }
    }
    else if (authModel.favourites.isNotEmpty) {
      _favourites = await authModel.fetchProductsFromFavourites();
      setState(() {});  
    }
    favouritesLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    
    final authModel = Provider.of<AuthModel>(context);
    if (authModel.favouritesLoaded && _favourites.isEmpty) {
      for (var prod in _favourites) {
        if (!authModel.favourites.any((fav) => fav.productId == prod.id)) {
          _favourites.remove(prod);
        }
      }
    } else if (!authModel.favouritesLoaded && authModel.isAuth) {
      _loadFavourites();
    }
    return Consumer<AuthModel>(
      builder: (context, authModel, child) {
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
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    title: Text(
                      "Избранное",
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      // IconButton(

                      // ),
                    ],
                  ),
                  favouritesLoaded ? _favourites.isNotEmpty ? SliverPadding(
                          padding: EdgeInsetsGeometry.all(10),
                          sliver: SliverGrid.builder(
                            itemBuilder: (context, i) {
                              return ProductCard(product: _favourites[i]);
                            },
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 7,
                              crossAxisSpacing: 4,
                              childAspectRatio: 0.6,
                            ),
                            itemCount: _favourites.length,
                          ),
                        ) : SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsetsGeometry.symmetric(vertical: 50),
                            child: Center(
                              child: Column(
                                children: [
                                  Text("Избранное пусто", style: TextStyle(fontSize: 30)),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Navigator.pushNamed(context, '/catalog');
                                    },
                                    child: Text("Перейти в каталог"),
                                  ),
                                ],
                              ),
                            ),
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
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

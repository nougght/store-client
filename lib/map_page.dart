import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';
import 'dart:async';

import 'package:yandex_maps_mapkit/mapkit.dart' as mk;
import 'package:yandex_maps_mapkit/yandex_map.dart';
import 'package:yandex_maps_mapkit/mapkit_factory.dart';
import 'package:yandex_maps_mapkit/places.dart';
import 'package:yandex_maps_mapkit/image.dart' as ip;
import 'package:yandex_maps_mapkit/search.dart';
import 'package:yandex_maps_mapkit/directions.dart';
import 'package:yandex_maps_mapkit/runtime.dart';
import 'package:yandex_maps_mapkit/transport.dart';
// import 'yandexs';

import 'classes.dart';

// Страница оплаты заказа

final class MapInputListenerImpl implements mk.MapInputListener {
  final void Function(mk.Map, mk.Point) onMapTapCB;
  final void Function(mk.Map, mk.Point) onMapLongTapCB;

  const MapInputListenerImpl(this.onMapTapCB, this.onMapLongTapCB);

  @override
  void onMapTap(mk.Map map, mk.Point point) => onMapTapCB(map, point);

  @override
  void onMapLongTap(mk.Map map, mk.Point point) => onMapLongTapCB(map, point);
}

final class MapCameraListenerImpl implements mk.MapCameraListener {
  final void Function(mk.Map, mk.CameraPosition) onCameraMoveCB;
  Timer? _timer;
  MapCameraListenerImpl(this.onCameraMoveCB);

  @override
  void onCameraPositionChanged(
    mk.Map map,
    mk.CameraPosition cameraPosition,
    mk.CameraUpdateReason r,
    b,
  ) {
    _timer?.cancel();
    if (r == mk.CameraUpdateReason.Gestures) {
      _timer = Timer(Duration(milliseconds: 500), () => onCameraMoveCB(map, cameraPosition));
    }
  }
}

class MapPage extends StatefulWidget {
  MapPage({super.key, this.selectedAdress, Point<double>? point}) {
    selectedPoint = point == null ? null : mk.Point(latitude: point.y, longitude: point.x);
  }
  mk.Point? selectedPoint;
  String? selectedAdress;

  @override
  State<StatefulWidget> createState() {
    return _MapPageState();
  }
}

class _MapPageState extends State<MapPage> {
  late mk.MapWindow _mapWindow;
  late SearchManager _searchManager;
  late SearchSuggestSession _suggestSession;

  late final _suggestSessionListener = SearchSuggestSessionSuggestListener(
    onResponse: (response) {
      setState(() {
        _suggestions = response.items.take(5).toList();
      });
    },
    onError: (error) {
      debugPrint('error${error.toString()}');
    },
  );

  late final _searchListener = SearchSessionSearchListener(
    onSearchResponse: (response) async {
      if (response.collection.children.isNotEmpty) {
        final boundingBox = response.metadata.boundingBox;
        if (boundingBox != null) {
          final mk.Point? point = response.collection.children.first
              .asGeoObject()!
              .geometry
              .firstOrNull!
              .asPoint();
          if (point == null) return;
          setState(() {
            widget.selectedPoint = point;
            widget.selectedAdress = response.collection.children.first.asGeoObject()!.name;
          });

          _mapWindow.map.moveWithAnimation(
            mk.CameraPosition(widget.selectedPoint!, zoom: 19, azimuth: 0, tilt: 0),
            mk.Animation(mk.AnimationType.Smooth, duration: 0.5),
          );
          // final imageProvider = ip.ImageProvider.fromImageProvider(
          //   const AssetImage("assets/icons/pin.png"),
          // );

          // final pm = _mapWindow.map.mapObjects.addPlacemark()
          //   ..geometry = point;
          // pm.useCompositeIcon().setIcon(imageProvider, mk.IconStyle(scale: 0.3, anchor: Point(0.5, 0.9)), name: 'icon');
        }
      }
    },
    onSearchError: (error) {
      debugPrint('error${error.toString()}');
    },
  );

  late final mapInputListener = MapInputListenerImpl((map, point) async {
    widget.selectedPoint = point;
    onCameraMove(
      map,
      mk.CameraPosition(point, zoom: _mapWindow.map.cameraPosition.zoom, azimuth: 0, tilt: 0),
    );
  }, (_, __) {});

  late final mapCameraListener = MapCameraListenerImpl((map, cameraPosition) async {
    onCameraMove(map, cameraPosition);
  });
  List<SuggestItem> _suggestions = [];

  mk.Point? _currentPoint;
  @override
  void initState() {
    super.initState();
    _initLocation();
    _searchManager = SearchFactory.instance.createSearchManager(SearchManagerType.Combined);
    _suggestSession = _searchManager.createSuggestSession();
  }

  void onCameraMove(mk.Map map, mk.CameraPosition cameraPosition) async {
    widget.selectedPoint = cameraPosition.target;
    // debugPrint('widget.selectedPoint: ${widget.selectedPoint}');
    final response = await _searchManager.submitPoint(
      widget.selectedPoint!,
      SearchOptions(),
      SearchSessionSearchListener(
        onSearchResponse: (response) async {
          if (response.collection.children.isNotEmpty) {
            final boundingBox = response.metadata.boundingBox;
            if (boundingBox != null) {
              final mk.Point? point = response.collection.children.first
                  .asGeoObject()!
                  .geometry
                  .firstOrNull!
                  .asPoint();
              if (point == null) return;
              setState(() {
                widget.selectedPoint = point;
                widget.selectedAdress = response.collection.children.first.asGeoObject()!.name;
              });

              _mapWindow.map.moveWithAnimation(
                mk.CameraPosition(
                  widget.selectedPoint!,
                  zoom: _mapWindow.map.cameraPosition.zoom,
                  azimuth: 0,
                  tilt: 0,
                ),
                mk.Animation(mk.AnimationType.Smooth, duration: 0.2),
              );
            }
          }
        },
        onSearchError: (error) {
          debugPrint('error${error.toString()}');
        },
      ),
      zoom: map.cameraPosition.zoom.toInt(),
    );
  }

  void fetchSuggestions(String query) async {
    if (query == '') {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    _suggestSession.suggest(
      mk.BoundingBox(
        _mapWindow.map.visibleRegion.bottomLeft,
        _mapWindow.map.visibleRegion.topRight,
      ),
      SuggestOptions(suggestTypes: SuggestType.Geo),
      _suggestSessionListener,

      text: query,
    );
  }

  void onSuggestionSelected(SuggestItem item) async {
    final _searchSession = _searchManager.searchByURI(
      SearchOptions(),
      _searchListener,
      uri: item.uri ?? '',
    );

    _mapWindow.map.moveWithAnimation(
      mk.CameraPosition(widget.selectedPoint!, zoom: 19, azimuth: 0, tilt: 0),
      mk.Animation(mk.AnimationType.Smooth, duration: 0.5),
    );
    setState(() {
      _suggestions.clear();
    });
  }

  Future<void> _initLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // await Geolocator.openLocationSettings();
      return;
    }
    final pos = await Geolocator.getCurrentPosition();
    mounted ? setState(() {
      _currentPoint = mk.Point(latitude: pos.latitude, longitude: pos.longitude);
    }) : null;

    // _currentPoint = await Geolocator.getCurrentPosition().then(
    //   (value) => mk.Point(latitude: value.latitude, longitude: value.longitude),
    // );
  }

  void _goToCurrentLocation() async {
    if (_currentPoint != null && _mapWindow != null) {
      final response = await _searchManager.submitPoint(
        _currentPoint!,
        SearchOptions(),
        SearchSessionSearchListener(
          onSearchResponse: (response) async {
            if (response.collection.children.isNotEmpty) {
              final boundingBox = response.metadata.boundingBox;
              if (boundingBox != null) {
                final mk.Point? point = response.collection.children.first
                    .asGeoObject()!
                    .geometry
                    .firstOrNull!
                    .asPoint();
                if (point == null) return;
                setState(() {
                  widget.selectedPoint = point;
                  widget.selectedAdress = response.collection.children.first.asGeoObject()!.name;
                });
              }
            }
          },
          onSearchError: (error) {
            debugPrint('error${error.toString()}');
          },
        ),
        zoom: _mapWindow.map.cameraPosition.zoom.toInt(),
      );
    _mapWindow.map.moveWithAnimation(
      mk.CameraPosition(_currentPoint!, zoom: 19, azimuth: 0, tilt: 0),
      mk.Animation(mk.AnimationType.Smooth, duration: 0.5),
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            right: 0,
            left: 0,
            child: Container(
              height: 500,
              child: YandexMap(
                onMapCreated: (mapWindow) {
                  _mapWindow = mapWindow;
                  _mapWindow.map.move(
                    mk.CameraPosition(
                      mk.Point(latitude: 43.8, longitude: 43.6),
                      zoom: 10,
                      azimuth: 0,
                      tilt: 0,
                    ),
                  );
                  mapkit.onStart();
                  _mapWindow.map.addInputListener(mapInputListener);
                  _mapWindow.map.addCameraListener(mapCameraListener);

                  final _searchSession = _searchManager.submit(
                    mk.Geometry.fromBoundingBox(
                      mk.BoundingBox(
                        _mapWindow.map.visibleRegion.bottomLeft,
                        _mapWindow.map.visibleRegion.topRight,
                      ),
                    ),
                    SearchOptions(),
                    SearchSessionSearchListener(
                      onSearchResponse: (response) {
                        if (response.collection.children.isNotEmpty) {
                          final boundingBox = response.metadata.boundingBox;
                          if (boundingBox != null) {
                            final mk.Point? point = response.collection.children.first
                                .asGeoObject()!
                                .geometry
                                .firstOrNull!
                                .asPoint();
                            if (point == null) return;
                            setState(() {
                              widget.selectedPoint = point;
                              widget.selectedAdress = response.collection.children.first
                                  .asGeoObject()!
                                  .name;
                            });

                            _mapWindow.map.move(
                              mk.CameraPosition(point, zoom: 12, azimuth: 0, tilt: 0),
                            );
                          }
                        }
                      },
                      onSearchError: (error) {},
                    ),

                    text: widget.selectedAdress ?? 'Нальчик',
                  );
                },
              ),
            ),
          ),
          Center(child: Icon(Icons.location_on_rounded, size: 50, color: Colors.red)),
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Container(
              // margin: EdgeInsets.all(12),
              padding: EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 10),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 170, 230, 170),
                borderRadius: BorderRadiusGeometry.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: 10),
                      Text('Выберите адресс доставки', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Найти адрес',
                      filled: true,
                      fillColor: const Color.fromARGB(209, 243, 243, 243),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                    ),
                    onChanged: (value) => fetchSuggestions(value),
                  ),
                  SizedBox(),
                  if (_suggestions.isNotEmpty)
                    Container(
                      // color: Color.fromARGB(255, 222, 222, 222),
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.all(0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) => ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                          title: RichText(
                            text: TextSpan(
                              children: [
                                for (int i = 0; i < _suggestions[index].title!.text.length; i++)
                                  TextSpan(
                                    text: _suggestions[index].title!.text[i],
                                    style:
                                        _suggestions[index].title!.spans.any(
                                          (span) => i >= span.begin && i < span.end,
                                        )
                                        ? TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          )
                                        : TextStyle(color: Colors.black),
                                  ),
                              ],
                            ),
                          ),
                          subtitle: _suggestions[index].subtitle == null
                              ? null
                              : Text(_suggestions[index].subtitle!.text.toString()),
                          onTap: () => onSuggestionSelected(_suggestions[index]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(222, 243, 243, 243),
                  border: Border.all(color: Color.fromARGB(222, 164, 164, 164)),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: EdgeInsetsGeometry.only(left: 5, right: 5, top: 10, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        // color: Color.fromARGB(115, 170, 230, 170),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.not_listed_location_outlined, color: Colors.red),
                          SizedBox(width: 10),
                          Text(
                            widget.selectedAdress ?? "Выберите адрес", style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.selectedPoint != null) {
                          Navigator.pop(context, [widget.selectedAdress, Point<double>(widget.selectedPoint!.latitude, widget.selectedPoint!.longitude)]);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 170, 230, 170),
                        padding: EdgeInsetsGeometry.all(15),
                      ),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Доставить сюда",
                            style: TextStyle(fontSize: 25),
                            textAlign: TextAlign.center,
                          ),
                          // Text(
                          //   " (${widget.quantity ?? cartModel.cartItems.length})",
                          //   style: TextStyle(fontSize: 20),
                          // ),
                          // Expanded(child: Spacer()),
                          // Text(
                          //   "${widget.product != null ? widget.product!.price * widget.quantity! : cartModel.totalPrice.toStringAsFixed(2)} ₽",
                          //   style: TextStyle(fontSize: 20),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            right: 20,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              child: Icon(Icons.my_location_rounded),
              backgroundColor: Color.fromARGB(255, 170, 230, 170),
            ),
          ),
        ],
      ),
    );
  }
}

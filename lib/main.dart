import 'package:flutter/material.dart';

void main() {
  runApp(const TestApp()); // запуск приложения
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
  List<Widget> pages = <Widget>[
    Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(248, 133, 231, 166),
        title: Text("Тест", style: TextStyle(fontSize: 20)),
      ),
    ),
    CatalogPage(),
    Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(248, 133, 231, 166),
        title: Text("Корзина", style: TextStyle(fontSize: 20)),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
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
        ],

        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: pages[_selectedIndex],
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, this.name = '', this.imagePath = ''});

  final String name;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(78, 195, 212, 207),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      padding: EdgeInsetsGeometry.all(5),

      child: Column(
        children: [
          Text(name, style: TextStyle(fontSize: 20)),
          Expanded(
            child: imagePath == ""
                ? Placeholder()
                : Image.asset("assets/images/$imagePath"),
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

class _CalalogPageState extends State<CatalogPage> {
  String _filter = "";

  List<Widget> _filterCards() {
    List<Widget> res = [];
    for (int i = 0; i < widget.categories.values.length; i++) {
      if (_filter == "" ||
          widget.categories.keys
                  .elementAt(i)
                  .toLowerCase()
                  .indexOf(_filter.toLowerCase()) !=
              -1) {
        res.add(
          ProductCard(
            name: widget.categories.keys.elementAt(i),
            imagePath: widget.categories.values.elementAt(i),
          ),
        );
      }
    }
    return res;
    // return List.generate(
    //   widget.categories.values.length,
    //   (int index) {
    //     return widget.categories.keys.elementAt(index).indexOf(_filter) == -1 ? Null :
    //     ProductCard(
    //       name: widget.categories.keys.elementAt(index),
    //       imagePath: widget.categories.values.elementAt(index),
    //     );
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(248, 133, 231, 166),
        title: Padding(
          padding: EdgeInsetsGeometry.only(bottom: 5),
          child: TextField(
            onSubmitted: (value) {
              setState(() {
                _filter = value;
              });
            },
            onChanged: (value) {
              setState(() {
                _filter = value;
              });
            },
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
      body: Container(
        padding: EdgeInsetsGeometry.only(top: 10),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                padding: EdgeInsetsGeometry.all(15),
                crossAxisCount: 2,
                scrollDirection: Axis.vertical,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,

                children: _filterCards(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _restartCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: _restartCounter,
              child: const Text('Restart counter'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

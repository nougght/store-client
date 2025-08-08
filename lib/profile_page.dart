import 'package:flutter/material.dart';
import 'package:mobile_store/favourites_page.dart';
import 'package:mobile_store/settings_page.dart';
import 'package:provider/provider.dart';
import 'models/auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<dynamic> data = [];

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context);
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Color.fromARGB(255, 170, 230, 170),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                pinned: true,
                leading: Icon(Icons.person_rounded),
                title: Text(
                  authModel.currentUser!.username,
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                actions: [
                  // IconButton(

                  // ),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => FavouritesPage()));
                    },
                    child: Row(
                      children: [
                        Icon(Icons.bookmark_rounded),
                        SizedBox(width: 10),
                        Text('Избранное', style: TextStyle(fontSize: 20)),
                        Spacer(),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0, // Убирает тень
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      padding: EdgeInsetsGeometry.all(10),
                    ),
                  ),
                  Divider(height: 1),
                  ElevatedButton(
                    onPressed: () => print('Кнопка 1'),
                    child: Row(
                      children: [
                        Icon(Icons.history),
                        SizedBox(width: 10),
                        Text('История', style: TextStyle(fontSize: 20)),
                        Spacer(),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0, // Убирает тень
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      padding: EdgeInsetsGeometry.all(10),
                    ),
                  ),
                  Divider(height: 1),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage())),
                    
                    style: ElevatedButton.styleFrom(
                      elevation: 0, // Убирает тень
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      padding: EdgeInsetsGeometry.all(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 10),
                        Text('Настройки', style: TextStyle(fontSize: 20)),
                        Spacer(),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => authModel.logout(),
                      style: ElevatedButton.styleFrom(
                        elevation: 0, // Убирает тень
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: EdgeInsetsGeometry.all(10),
                        
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.red,),
                          SizedBox(width: 10),
                          Text('Выход', style: TextStyle(fontSize: 20, color: Colors.red)),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

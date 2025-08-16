import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_store/payment_page.dart';
import 'package:provider/provider.dart';
import 'models/cart.dart';
import 'classes.dart';
import 'models/auth.dart';
import 'cards.dart';
import 'models/settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settingsModel = Provider.of<SettingsModel>(context);
    final authModel = Provider.of<AuthModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Настройки")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Тема приложения", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Светлая"),
                Switch(
                  value: settingsModel.isDarkMode,
                  onChanged: (val) {
                    settingsModel.setTheme(isDark: val);

                    // SystemChrome.setSystemUIOverlayStyle(
                    //   SystemUiOverlayStyle(
                    //     statusBarColor: value ? Colors.white : Colors.black,
                    //     statusBarIconBrightness: value ? Brightness.dark : Brightness.light,
                    //   ),
                    // );
                  },
                ),
                Text("Темная"),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                authModel.deleteAccount();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                elevation: 0, // Убирает тень
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                padding: EdgeInsetsGeometry.all(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.no_accounts_rounded, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Удалить аккаунт', style: TextStyle(fontSize: 20, color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

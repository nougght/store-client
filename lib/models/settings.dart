import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:mobile_store/classes.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store/classes.dart' as classes;
import 'package:mobile_store/services/api_service.dart';
import 'package:flutter/material.dart';

class SettingsModel with ChangeNotifier {
  final ApiService api;
  bool settingsLoaded = false;
  String? selectedLanguage;
  String? selectedCurrency;
  // добавить кэширование настроек
  bool isDarkMode = false;

  final lightTheme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: Color.fromARGB(255, 38, 100, 60),
      secondary: Color.fromARGB(255, 174, 221, 234),
      onSecondary: Color.fromARGB(222, 5, 5, 5),
      onSurface: Color.fromARGB(255, 66, 66, 66),
    ),
  );
  final darkTheme = ThemeData(
    colorScheme: ColorScheme.dark(
    ), 
  );


  SettingsModel(this.api);

  ThemeData get currentTheme {
    return isDarkMode ? darkTheme : lightTheme;
  }

  void setTheme({bool isDark = false}) {
    isDarkMode = isDark;
    notifyListeners();
  }

  Future<void> fetchSettings() async {
    // Здесь можно добавить логику для загрузки настроек из API
    settingsLoaded = true;
    notifyListeners();
  }

  void setLanguage(String language) {
    selectedLanguage = language;
    notifyListeners();
  }

  void setCurrency(String currency) {
    selectedCurrency = currency;
    notifyListeners();
  }

  // void set
}

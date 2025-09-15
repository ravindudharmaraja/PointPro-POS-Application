import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  // Default colors
  static const Color defaultPrimaryColor = Color(0xffF9443A);
  static const Color defaultSecondaryColor = Color.fromARGB(255, 250, 146, 49);

  // Internal state variables (non-const)
  late Color _primaryColor;
  late Color _secondaryColor;

  ThemeProvider() {
    _primaryColor = defaultPrimaryColor;
    _secondaryColor = defaultSecondaryColor;
    _loadPreferences();
  }

  ThemeMode get themeMode => _themeMode;
  Color get appPrimaryColor => _primaryColor;
  Color get appSecondaryColor => _secondaryColor;

  ThemeData get currentTheme =>
      _themeMode == ThemeMode.light ? lightTheme : darkTheme;

  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: _primaryColor,
        colorScheme: ColorScheme.light(
          primary: _primaryColor,
          secondary: _secondaryColor,
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        cardColor: const Color.fromARGB(255, 253, 253, 253),
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: _primaryColor,
        colorScheme: ColorScheme.dark(
          primary: _primaryColor,
          secondary: _secondaryColor,
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 18, 16),
        cardColor: const Color.fromARGB(255, 26, 26, 26),
      );

  // Load saved theme mode and colors from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme mode
    final themeModeString = prefs.getString('theme_mode');
    if (themeModeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeModeString,
        orElse: () => ThemeMode.light,
      );
    } else {
      _themeMode = ThemeMode.light;
    }

    // Load primary color (stored as int)
    final primaryColorValue = prefs.getInt('primary_color');
    if (primaryColorValue != null) {
      _primaryColor = Color(primaryColorValue);
    } else {
      _primaryColor = defaultPrimaryColor;
    }

    // Load secondary color (optional)
    final secondaryColorValue = prefs.getInt('secondary_color');
    if (secondaryColorValue != null) {
      _secondaryColor = Color(secondaryColorValue);
    } else {
      _secondaryColor = defaultSecondaryColor;
    }

    notifyListeners();
  }

  // Set theme mode and save it
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.toString());
  }

  // Set primary color and save it
  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primary_color', color.value);
  }

  // Optionally, add setter for secondary color if you want
  Future<void> setSecondaryColor(Color color) async {
    _secondaryColor = color;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('secondary_color', color.value);
  }
}

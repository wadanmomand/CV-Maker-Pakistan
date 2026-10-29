import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _keyLanguage = 'selected_language';
  static const String _keyThemeMode = 'selected_theme_mode';

  AppLanguage _language = AppLanguage.romanUrdu; // Roman Urdu is default
  ThemeMode _themeMode = ThemeMode.light; // Light is default

  AppLanguage get language => _language;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  AppStrings get strings => AppStrings(_language);

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final langIndex = prefs.getInt(_keyLanguage);
    if (langIndex != null && langIndex < AppLanguage.values.length) {
      _language = AppLanguage.values[langIndex];
    } else {
      _language = AppLanguage.romanUrdu;
    }

    final themeIndex = prefs.getInt(_keyThemeMode);
    if (themeIndex != null) {
      _themeMode = themeIndex == 1 ? ThemeMode.dark : ThemeMode.light;
    } else {
      _themeMode = ThemeMode.light;
    }

    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) return;
    _language = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLanguage, language.index);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode == ThemeMode.dark ? 1 : 0);
  }
}

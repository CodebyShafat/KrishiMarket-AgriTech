import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  Locale _currentLocale = const Locale('hi'); // Hindi default

  Locale get currentLocale => _currentLocale;

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString(_languageKey);
    if (savedLang != null) {
      _currentLocale = Locale(savedLang);
      notifyListeners();
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    if (_currentLocale.languageCode == languageCode) return;
    _currentLocale = Locale(languageCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }
}

class AppLanguage extends InheritedNotifier<LanguageProvider> {
  const AppLanguage({super.key, required super.notifier, required super.child});

  static LanguageProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppLanguage>()!.notifier!;
  }
}

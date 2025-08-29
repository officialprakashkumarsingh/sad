import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class WebSearchService extends ChangeNotifier {
  static final WebSearchService instance = WebSearchService._internal();
  WebSearchService._internal();

  bool _isWebSearchEnabled = false;
  bool get isWebSearchEnabled => _isWebSearchEnabled;

  Future<void> loadWebSearchSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _isWebSearchEnabled = prefs.getBool('web_search_enabled') ?? false;
    notifyListeners();
  }

  Future<void> setWebSearchEnabled(bool value) async {
    _isWebSearchEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('web_search_enabled', value);
    notifyListeners();
  }
}

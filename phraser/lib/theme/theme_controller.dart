import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


class ThemeController extends GetxController {
  final _storage = GetStorage();
  final _themeKey = 'app_theme';

  ThemeMode get themeMode => _loadTheme();
  ThemeMode get initialValue => _loadTheme();

  ThemeMode _loadTheme() {
    final _savedTheme = _storage.read(_themeKey) ?? ThemeMode.system;
    if (_savedTheme == ThemeMode.system.toString()) {
      return ThemeMode.system;
    } else if (_savedTheme == ThemeMode.light.toString()) {
      return ThemeMode.light;
    } else if (_savedTheme == ThemeMode.dark.toString()) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }

  saveTheme(ThemeMode themeMode) {
    _storage.write(_themeKey, themeMode.toString());
  }

  switchTheme() {
    Get.changeThemeMode(_loadTheme());
  }
}

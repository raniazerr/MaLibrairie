import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

const String _themePrefKey = 'isDarkMode';

Future<void> loadThemePreference() async {
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool(_themePrefKey) ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
}

Future<void> toggleTheme() async {
  final isDark = themeNotifier.value == ThemeMode.dark;
  themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_themePrefKey, !isDark);
}
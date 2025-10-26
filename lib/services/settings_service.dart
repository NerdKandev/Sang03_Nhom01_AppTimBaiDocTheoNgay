import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final bool isDark;
  final double textScaleFactor;

  const AppSettings({required this.isDark, required this.textScaleFactor});

  AppSettings copyWith({bool? isDark, double? textScaleFactor}) {
    return AppSettings(
      isDark: isDark ?? this.isDark,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
    );
  }
}

final ValueNotifier<AppSettings> settingsNotifier =
    ValueNotifier(const AppSettings(isDark: false, textScaleFactor: 1.0));

Future<void> loadSettingsFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('settings_isDark') ?? false;
  final font = prefs.getString('settings_fontSize') ?? 'Bình thường';
  final textScale = _fontToScale(font);
  settingsNotifier.value = AppSettings(isDark: isDark, textScaleFactor: textScale);
}

double _fontToScale(String font) {
  switch (font) {
    case 'Nhỏ':
      return 0.9;
    case 'Lớn':
      return 1.2;
    case 'Bình thường':
    default:
      return 1.0;
  }
}

Future<void> saveIsDark(bool v) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('settings_isDark', v);
  settingsNotifier.value = settingsNotifier.value.copyWith(isDark: v);
}

Future<void> saveFont(String font) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('settings_fontSize', font);
  settingsNotifier.value = settingsNotifier.value.copyWith(textScaleFactor: _fontToScale(font));
}

Future<void> saveLanguage(String lang) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('settings_language', lang);
}

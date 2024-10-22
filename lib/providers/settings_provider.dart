import 'package:flutter/material.dart';
import 'package:flutter_gemini/hive/boxes.dart';
import 'package:flutter_gemini/hive/settings.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _shouldSpeak = false;

  bool get isDarkMode => _isDarkMode;

  bool get shouldSpeak => _shouldSpeak;

  void getSavedSettings() {
    final settingsBox = Boxes.getSettings();

    if (settingsBox.isNotEmpty) {
      final settings = settingsBox.getAt(0);
      _isDarkMode = settings!.isDarkTheme;
      _shouldSpeak = settings.shouldSpeak;
    }
  }

  void toggleDarkMode({
    required bool value,
    Settings? settings,
  }) {
    if (settings != null) {
      settings.isDarkTheme = value;
      settings.save();
    } else {
      final settingsBox = Boxes.getSettings();
      settingsBox.put(
          0, Settings(isDarkTheme: value, shouldSpeak: shouldSpeak));
    }

    _isDarkMode = value;
    notifyListeners();
  }
}

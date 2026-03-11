import 'package:flutter/material.dart';
import 'settings_model.dart';
import 'settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _service = SettingsService();

  SettingsModel _settings = SettingsModel.defaults();

  SettingsModel get settings => _settings;

  bool get darkMode => _settings.darkMode;
  String get language => _settings.language;
  bool get notifications => _settings.notificationsEnabled;

  Future<void> loadSettings() async {
    _settings = await _service.loadSettings();
    notifyListeners();
  }

  Future<void> updateDarkMode(bool value) async {
    _settings = _settings.copyWith(darkMode: value);
    await _service.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateLanguage(String lang) async {
    _settings = _settings.copyWith(language: lang);
    await _service.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateNotifications(bool value) async {
    _settings = _settings.copyWith(notificationsEnabled: value);
    await _service.saveSettings(_settings);
    notifyListeners();
  }
}

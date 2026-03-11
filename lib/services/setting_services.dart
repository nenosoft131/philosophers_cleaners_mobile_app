import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/setting_model.dart';

class SettingsService {
  static const String settingsKey = "app_settings";

  Future<void> saveSettings(SettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(settings.toJson());
    await prefs.setString(settingsKey, jsonString);
  }

  Future<SettingsModel> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(settingsKey);

    if (jsonString == null) {
      return SettingsModel.defaults();
    }

    final Map<String, dynamic> json = jsonDecode(jsonString);
    return SettingsModel.fromJson(json);
  }

  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(settingsKey);
  }
}

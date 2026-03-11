class SettingsModel {
  final bool darkMode;
  final String language;
  final bool notificationsEnabled;

  SettingsModel({
    required this.darkMode,
    required this.language,
    required this.notificationsEnabled,
  });

  factory SettingsModel.defaults() {
    return SettingsModel(
      darkMode: false,
      language: "en",
      notificationsEnabled: true,
    );
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      darkMode: json["darkMode"] ?? false,
      language: json["language"] ?? "en",
      notificationsEnabled: json["notificationsEnabled"] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "darkMode": darkMode,
      "language": language,
      "notificationsEnabled": notificationsEnabled,
    };
  }

  SettingsModel copyWith({
    bool? darkMode,
    String? language,
    bool? notificationsEnabled,
  }) {
    return SettingsModel(
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

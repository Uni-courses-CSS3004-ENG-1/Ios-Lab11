import 'package:shared_preferences/shared_preferences.dart';

/// Small wrapper around [SharedPreferences].
///
/// All keys live here, so the UI never types a key string by hand.
class StorageService {
  StorageService(this._prefs);

  static const String darkModeKey = 'app_theme_dark_mode';
  static const String userNameKey = 'user_display_name';

  static const String defaultUserName = 'Guest User';

  final SharedPreferences _prefs;

  /// Opens the storage. Call this once in `main()` before `runApp()`.
  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // ---------- Theme (bool) ----------

  /// `null` on the very first launch, so we fall back to `false` (light mode).
  bool loadDarkMode() => _prefs.getBool(darkModeKey) ?? false;

  Future<void> saveDarkMode(bool isDark) => _prefs.setBool(darkModeKey, isDark);

  // ---------- Username (String) ----------

  String loadUserName() => _prefs.getString(userNameKey) ?? defaultUserName;

  Future<void> saveUserName(String name) =>
      _prefs.setString(userNameKey, name.trim());
}

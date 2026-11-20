import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note_item.dart';

/// Small wrapper around [SharedPreferences].
///
/// All keys live here, so the UI never types a key string by hand.
class StorageService {
  StorageService(this._prefs);

  static const String darkModeKey = 'app_theme_dark_mode';
  static const String userNameKey = 'user_display_name';
  static const String notesKey = 'saved_notes_list';

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

  // ---------- Notes (List<NoteItem> as one JSON String) ----------

  /// String on disk → `jsonDecode` → List of Maps → `NoteItem.fromJson`.
  List<NoteItem> loadNotes() {
    final jsonText = _prefs.getString(notesKey);
    if (jsonText == null || jsonText.isEmpty) return [];

    try {
      final list = jsonDecode(jsonText) as List<dynamic>;
      return list
          .map((item) => NoteItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return []; // broken JSON on disk: start with an empty list
    } on TypeError {
      return []; // valid JSON but not a list of objects
    }
  }

  /// `toJson` on every note → `jsonEncode` → one String on disk.
  Future<void> saveNotes(List<NoteItem> notes) {
    final jsonText = jsonEncode(notes.map((note) => note.toJson()).toList());
    return _prefs.setString(notesKey, jsonText);
  }
}

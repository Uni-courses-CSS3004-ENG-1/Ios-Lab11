# Lab 11: Offline-First Notes & Settings Vault

Single-screen Flutter app that keeps all of its state on disk with
[`shared_preferences: ^2.2.2`](https://pub.dev/packages/shared_preferences).
Force-quit it, open it again, and everything is still there.

## Run

```bash
flutter pub get
flutter run
flutter test
```

## Project structure

```
lib/
├── main.dart                     # ensureInitialized → load storage → runApp
├── models/note_item.dart         # NoteItem + toJson() / factory fromJson()
├── services/storage_service.dart # all SharedPreferences keys + read/write
├── screens/home_screen.dart      # header, username, Dark Mode, notes CRUD
└── widgets/note_tile.dart        # checkbox, delete button, swipe to delete
```

## Theme persistence (no flicker)

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();   // plugins work before runApp
  final storage = await StorageService.init(); // SharedPreferences.getInstance()
  runApp(VaultApp(storage: storage));
}
```

`VaultApp` reads `storage.loadDarkMode()` (`getBool('app_theme_dark_mode') ?? false`)
**synchronously** when it is created, so the first frame `MaterialApp` draws already
has the right `themeMode`. If we loaded it in `initState` with `await`, the app would
draw one light frame first and then jump to dark: that is the white flash.

When the switch changes: `setState` (UI updates at once) → `setBool` (written to disk).

## Username persistence

| Action | Call |
|---|---|
| Save button | `prefs.setString('user_display_name', name)` |
| App launch | `prefs.getString('user_display_name') ?? 'Guest User'` |

The saved name shows up in the "Welcome back" header and is pre-filled in the text field.

## Notes list with JSON

`SharedPreferences` can only store simple types, so the whole `List<NoteItem>` is
stored as **one JSON string** under `saved_notes_list`.

```
Save:  List<NoteItem> → .map(toJson) → List<Map> → jsonEncode → String → setString
Load:  getString → String → jsonDecode → List<dynamic> → .map(fromJson) → List<NoteItem>
```

| Action | What happens |
|---|---|
| **Add** | `_notes.insert(0, note)` (newest on top) → `saveNotes` |
| **Toggle** | checkbox (or tap the row) → `copyWith(isCompleted: !done)` → `saveNotes` |
| **Delete** | 🗑 button or swipe left → `removeAt` → `saveNotes` right away (SnackBar has **UNDO**) |

If the stored string is broken, `loadNotes()` catches the error and returns an empty
list, so the app still opens.

## Cold Restart Test (defense)

1. `flutter run` on the simulator.
2. Add 2 notes, tick one, type a name and tap **Save**, turn on **Dark Mode**.
3. Kill the process: **Cmd+Shift+H** twice → swipe the app up in the app switcher
   (or press `q` in the `flutter run` terminal).
4. Tap the app icon again. It opens **dark from the very first frame**, with the name
   in the header and both notes (with their checkbox state).

`test/cold_restart_test.dart` does the same in code: it throws away the widget tree and
builds a new app from what is on disk.

## Defense Q&A: SharedPreferences vs Keychain / KeyStore

| | SharedPreferences | Keychain (iOS) / KeyStore (Android) |
|---|---|---|
| Stored as | Plain text: `NSUserDefaults` .plist on iOS, XML file on Android | Encrypted by the OS, keys can be hardware-backed |
| Good for | Theme, username, small caches, these notes | Passwords, auth tokens, API keys, card data |
| Risk | Readable from a backup, a jailbroken/rooted phone, or a debug build | Hard to read even with file access |
| Flutter package | `shared_preferences` | `flutter_secure_storage` |

**Rule:** if leaking it would hurt the user, it goes into the Keychain/KeyStore, not
SharedPreferences.

Other quick answers:
- **Why `ensureInitialized()`?** `SharedPreferences.getInstance()` talks to native code
  through a platform channel. The channel needs the Flutter binding, and `runApp()`
  normally creates it. We call the plugin *before* `runApp()`, so we create it ourselves.
- **Why load the theme in `main()`?** So the first frame already knows the theme. Loading
  it later with `await` in `initState` draws one light frame first: the white flash.
- **Why `??`?** On the first launch the key does not exist and `getBool`/`getString`
  return `null`. `?? false` / `?? 'Guest User'` give a safe default.
- **Limits:** SharedPreferences is for small data. For big or queryable data use SQLite
  (`sqflite`), `drift` or Hive.

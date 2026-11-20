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
├── services/storage_service.dart # all SharedPreferences keys + read/write
└── screens/home_screen.dart      # header, username field, Dark Mode switch
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

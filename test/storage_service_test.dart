import 'package:flutter_test/flutter_test.dart';
import 'package:offline_notes_vault/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<StorageService> freshStorage([Map<String, Object> values = const {}]) {
    SharedPreferences.setMockInitialValues(values);
    return StorageService.init();
  }

  test('first launch falls back to light mode and Guest User', () async {
    final storage = await freshStorage();
    expect(storage.loadDarkMode(), isFalse);
    expect(storage.loadUserName(), 'Guest User');
  });

  test('dark mode is saved under app_theme_dark_mode', () async {
    final storage = await freshStorage();
    await storage.saveDarkMode(true);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('app_theme_dark_mode'), isTrue);
    expect(storage.loadDarkMode(), isTrue);
  });

  test('username is trimmed and saved under user_display_name', () async {
    final storage = await freshStorage();
    await storage.saveUserName('  Abror  ');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('user_display_name'), 'Abror');
    expect(storage.loadUserName(), 'Abror');
  });
}

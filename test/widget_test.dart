import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_notes_vault/main.dart';
import 'package:offline_notes_vault/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, Map<String, Object> saved) async {
    SharedPreferences.setMockInitialValues(saved);
    final storage = await StorageService.init();
    await tester.pumpWidget(VaultApp(storage: storage));
  }

  ThemeMode themeMode(WidgetTester tester) =>
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;

  testWidgets('first frame is already dark when dark mode was saved', (
    tester,
  ) async {
    await pumpApp(tester, {'app_theme_dark_mode': true});
    expect(themeMode(tester), ThemeMode.dark);
  });

  testWidgets('defaults to light mode on first launch', (tester) async {
    await pumpApp(tester, {});
    expect(themeMode(tester), ThemeMode.light);
  });

  testWidgets('Dark Mode switch changes the theme and saves it to disk', (
    tester,
  ) async {
    await pumpApp(tester, {});

    await tester.tap(find.byKey(const Key('darkModeSwitch')));
    await tester.pumpAndSettle();

    expect(themeMode(tester), ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('app_theme_dark_mode'), isTrue);
  });
}

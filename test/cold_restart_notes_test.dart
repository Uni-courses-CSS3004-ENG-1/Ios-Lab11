import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_notes_vault/main.dart';
import 'package:offline_notes_vault/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The full lab scenario: add 2 notes, toggle one, dark mode on, kill, reopen.
void main() {
  testWidgets('notes, checkbox state and dark mode survive a cold restart', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(VaultApp(storage: await StorageService.init()));

    for (final title in ['Read chapter 11', 'Prepare defense']) {
      await tester.enterText(find.byKey(const Key('noteField')), title);
      await tester.tap(find.byKey(const Key('addNoteButton')));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byType(Checkbox).first); // "Prepare defense"
    await tester.tap(find.byKey(const Key('darkModeSwitch')));
    await tester.pumpAndSettle();

    // Force-quit: throw the app away, then start a new one from disk.
    await tester.pumpWidget(const SizedBox());
    final storage = await StorageService.init();
    await tester.pumpWidget(VaultApp(key: UniqueKey(), storage: storage));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(find.text('My Notes (2)'), findsOneWidget);

    final boxes = tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
    expect(boxes.map((b) => b.value), [true, false]);
    expect(storage.loadNotes().map((n) => n.title), [
      'Prepare defense',
      'Read chapter 11',
    ]);
  });
}

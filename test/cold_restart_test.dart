import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_notes_vault/main.dart';
import 'package:offline_notes_vault/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simulates "force-quit and reopen": the widget tree is thrown away and a
/// brand-new app is built from whatever is stored on disk.
Future<void> coldRestart(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox()); // kill the old app
  final storage = await StorageService.init(); // like main() on next launch
  await tester.pumpWidget(VaultApp(key: UniqueKey(), storage: storage));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('theme and username survive a cold restart', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(VaultApp(storage: await StorageService.init()));

    await tester.tap(find.byKey(const Key('darkModeSwitch')));
    await tester.enterText(find.byKey(const Key('userNameField')), 'Abror');
    await tester.tap(find.byKey(const Key('saveUserNameButton')));
    await tester.pumpAndSettle();

    await coldRestart(tester);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(
      tester.widget<Text>(find.byKey(const Key('headerUserName'))).data,
      'Abror',
    );
  });
}

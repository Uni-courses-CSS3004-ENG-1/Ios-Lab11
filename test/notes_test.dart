import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_notes_vault/main.dart';
import 'package:offline_notes_vault/screens/home_screen.dart';
import 'package:offline_notes_vault/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, [
    Map<String, Object> saved = const {},
  ]) async {
    // iPhone-sized screen so the notes below the settings are visible.
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues(saved);
    await tester.pumpWidget(VaultApp(storage: await StorageService.init()));
  }

  Future<void> addNote(WidgetTester tester, String title) async {
    await tester.enterText(find.byKey(const Key('noteField')), title);
    await tester.tap(find.byKey(const Key('addNoteButton')));
    await tester.pumpAndSettle();
  }

  Future<List<dynamic>> savedJson() async {
    final prefs = await SharedPreferences.getInstance();
    return jsonDecode(prefs.getString('saved_notes_list')!) as List<dynamic>;
  }

  test('formatDate gives day, month, year and time', () {
    expect(formatDate(DateTime(2026, 11, 20, 9, 5)), '20 Nov 2026, 09:05');
  });

  testWidgets('empty state when there are no notes', (tester) async {
    await pumpApp(tester);
    expect(find.text('No notes yet. Add your first one!'), findsOneWidget);
  });

  testWidgets('new notes are prepended and saved as JSON', (tester) async {
    await pumpApp(tester);
    await addNote(tester, 'First');
    await addNote(tester, 'Second');

    final json = await savedJson();
    expect(json.map((e) => e['title']), ['Second', 'First']);
    expect(json.first['isCompleted'], isFalse);
    expect(find.text('My Notes (2)'), findsOneWidget);
  });

  testWidgets('blank note is ignored', (tester) async {
    await pumpApp(tester);
    await addNote(tester, '   ');
    expect(find.text('My Notes (0)'), findsOneWidget);
  });

  testWidgets('saved notes are shown on launch', (tester) async {
    await pumpApp(tester, {
      'saved_notes_list': jsonEncode([
        {
          'id': '1',
          'title': 'From disk',
          'dateText': 'x',
          'isCompleted': false,
        },
      ]),
    });
    expect(find.text('From disk'), findsOneWidget);
  });

  final twoNotes = {
    'saved_notes_list': jsonEncode([
      {'id': 'a', 'title': 'Alpha', 'dateText': 'x', 'isCompleted': false},
      {'id': 'b', 'title': 'Beta', 'dateText': 'x', 'isCompleted': false},
    ]),
  };

  testWidgets('checkbox toggles completion and updates disk', (tester) async {
    await pumpApp(tester, twoNotes);

    await tester.tap(find.byKey(const ValueKey('check_b')));
    await tester.pumpAndSettle();
    expect((await savedJson())[1]['isCompleted'], isTrue);

    await tester.tap(find.byKey(const ValueKey('check_b')));
    await tester.pumpAndSettle();
    expect((await savedJson())[1]['isCompleted'], isFalse);
  });

  testWidgets('delete button removes the note from disk', (tester) async {
    await pumpApp(tester, twoNotes);

    await tester.tap(find.byKey(const ValueKey('delete_a')));
    await tester.pumpAndSettle();

    expect(find.text('Alpha'), findsNothing);
    expect((await savedJson()).map((e) => e['id']), ['b']);
  });

  testWidgets('swipe deletes and Undo puts the note back', (tester) async {
    await pumpApp(tester, twoNotes);

    await tester.drag(find.text('Alpha'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect((await savedJson()).map((e) => e['id']), ['b']);

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();
    expect((await savedJson()).map((e) => e['id']), ['a', 'b']);
  });
}

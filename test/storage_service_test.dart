import 'package:flutter_test/flutter_test.dart';
import 'package:offline_notes_vault/models/note_item.dart';
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

  test('notes are stored as one JSON string and read back', () async {
    final storage = await freshStorage();
    await storage.saveNotes(const [
      NoteItem(id: 'b', title: 'Second', dateText: 'today', isCompleted: true),
      NoteItem(id: 'a', title: 'First', dateText: 'today'),
    ]);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('saved_notes_list'), startsWith('[{"id":"b"'));

    final notes = storage.loadNotes();
    expect(notes.map((n) => n.title), ['Second', 'First']);
    expect(notes.first.isCompleted, isTrue);
  });

  test('no notes saved yet gives an empty list', () async {
    final storage = await freshStorage();
    expect(storage.loadNotes(), isEmpty);
  });

  test('broken JSON on disk gives an empty list instead of a crash', () async {
    final storage = await freshStorage({'saved_notes_list': '{oops'});
    expect(storage.loadNotes(), isEmpty);

    final notAList = await freshStorage({'saved_notes_list': '{"a":1}'});
    expect(notAList.loadNotes(), isEmpty);
  });
}

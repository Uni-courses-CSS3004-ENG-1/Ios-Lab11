import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:offline_notes_vault/models/note_item.dart';

void main() {
  const note = NoteItem(
    id: '1',
    title: 'Buy milk',
    dateText: '20 Nov 2026, 18:30',
    isCompleted: true,
  );

  test('toJson writes all four fields', () {
    expect(note.toJson(), {
      'id': '1',
      'title': 'Buy milk',
      'dateText': '20 Nov 2026, 18:30',
      'isCompleted': true,
    });
  });

  test('a list survives jsonEncode → jsonDecode → fromJson', () {
    final text = jsonEncode([note.toJson()]);
    final decoded = (jsonDecode(text) as List)
        .map((e) => NoteItem.fromJson(e as Map<String, dynamic>))
        .toList();

    expect(decoded, hasLength(1));
    expect(decoded.first.id, '1');
    expect(decoded.first.title, 'Buy milk');
    expect(decoded.first.dateText, '20 Nov 2026, 18:30');
    expect(decoded.first.isCompleted, isTrue);
  });

  test('fromJson uses defaults for missing fields', () {
    final empty = NoteItem.fromJson({});
    expect(empty.title, '');
    expect(empty.isCompleted, isFalse);
  });

  test('copyWith only changes isCompleted', () {
    final open = note.copyWith(isCompleted: false);
    expect(open.isCompleted, isFalse);
    expect(open.title, note.title);
    expect(open.id, note.id);
  });
}

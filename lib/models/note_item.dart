/// One note in the list. Immutable: a change makes a new object with [copyWith].
class NoteItem {
  const NoteItem({
    required this.id,
    required this.title,
    required this.dateText,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String dateText;
  final bool isCompleted;

  /// Dart object → Map. `jsonEncode` can turn this Map into a String.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'dateText': dateText,
    'isCompleted': isCompleted,
  };

  /// Map (from `jsonDecode`) → Dart object. Missing fields get safe defaults,
  /// so old or broken data on disk never crashes the app.
  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      dateText: json['dateText'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  NoteItem copyWith({bool? isCompleted}) => NoteItem(
    id: id,
    title: title,
    dateText: dateText,
    isCompleted: isCompleted ?? this.isCompleted,
  );
}

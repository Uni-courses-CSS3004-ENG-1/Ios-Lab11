import 'package:flutter/material.dart';

import '../models/note_item.dart';

/// One note: checkbox to toggle, swipe left or tap the bin to delete.
class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.onToggle,
    required this.onDelete,
  });

  final NoteItem note;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey('dismiss_${note.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete, color: colors.onError),
      ),
      child: Card(
        child: ListTile(
          leading: Checkbox(
            key: ValueKey('check_${note.id}'),
            value: note.isCompleted,
            onChanged: (_) => onToggle(),
          ),
          title: Text(
            note.title,
            style: TextStyle(
              decoration: note.isCompleted ? TextDecoration.lineThrough : null,
              color: note.isCompleted ? colors.outline : null,
            ),
          ),
          subtitle: Text(note.dateText),
          trailing: IconButton(
            key: ValueKey('delete_${note.id}'),
            tooltip: 'Delete note',
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
          onTap: onToggle,
        ),
      ),
    );
  }
}

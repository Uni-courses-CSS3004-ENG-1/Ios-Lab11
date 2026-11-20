import 'package:flutter/material.dart';

import '../models/note_item.dart';
import '../services/storage_service.dart';
import '../widgets/note_tile.dart';

/// The single screen of the app: settings on top, notes below.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.storage,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  final StorageService storage;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Read once on startup. Falls back to 'Guest User' when nothing is saved.
  late String _userName = widget.storage.loadUserName();

  // Auto-fill the field with the saved name (but leave it empty for a guest).
  late final TextEditingController _nameController = TextEditingController(
    text: _userName == StorageService.defaultUserName ? '' : _userName,
  );

  // Notes restored from the JSON string on disk.
  late final List<NoteItem> _notes = widget.storage.loadNotes();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// Every change to the list ends here: List → JSON string → disk.
  Future<void> _persistNotes() => widget.storage.saveNotes(_notes);

  Future<void> _addNote() async {
    final title = _noteController.text.trim();
    if (title.isEmpty) return;

    final now = DateTime.now();
    final note = NoteItem(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      dateText: formatDate(now),
    );

    setState(() => _notes.insert(0, note)); // prepend: newest on top
    _noteController.clear();
    await _persistNotes();
  }

  Future<void> _toggleNote(NoteItem note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index == -1) return;
    setState(() {
      _notes[index] = note.copyWith(isCompleted: !note.isCompleted);
    });
    await _persistNotes();
  }

  Future<void> _deleteNote(NoteItem note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index == -1) return;
    setState(() => _notes.removeAt(index));
    await _persistNotes(); // disk is updated right away, before any Undo

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Deleted "${note.title}"'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () async {
            setState(() => _notes.insert(index.clamp(0, _notes.length), note));
            await _persistNotes();
          },
        ),
      ),
    );
  }

  Future<void> _saveUserName() async {
    final name = _nameController.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    FocusScope.of(context).unfocus();

    if (name.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter a username first')),
      );
      return;
    }

    await widget.storage.saveUserName(name);
    setState(() => _userName = name);
    messenger.showSnackBar(SnackBar(content: Text('Saved "$name"')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes & Settings Vault')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileHeader(userName: _userName),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('userNameField'),
                      controller: _nameController,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.words,
                      onSubmitted: (_) => _saveUserName(),
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        hintText: 'Enter your name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    key: const Key('saveUserNameButton'),
                    onPressed: _saveUserName,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              key: const Key('darkModeSwitch'),
              secondary: Icon(
                widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              title: const Text('Dark Mode'),
              subtitle: const Text('Saved as app_theme_dark_mode'),
              value: widget.isDarkMode,
              onChanged: widget.onDarkModeChanged,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'My Notes (${_notes.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('noteField'),
                  controller: _noteController,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _addNote(),
                  decoration: const InputDecoration(
                    hintText: 'Write a new note…',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                key: const Key('addNoteButton'),
                tooltip: 'Add note',
                onPressed: _addNote,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_notes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text('No notes yet. Add your first one!')),
            )
          else
            for (final note in _notes)
              NoteTile(
                key: ValueKey(note.id),
                note: note,
                onToggle: () => _toggleNote(note),
                onDelete: () => _deleteNote(note),
              ),
        ],
      ),
    );
  }
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// `20 Nov 2026, 18:05`, without adding the intl package.
String formatDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.day} ${_months[d.month - 1]} ${d.year}, '
      '${two(d.hour)}:${two(d.minute)}';
}

/// "Welcome back, name" header at the top of the screen.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            child: Text(
              userName.characters.first.toUpperCase(),
              style: textTheme.titleLarge?.copyWith(color: colors.onPrimary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
                Text(
                  userName,
                  key: const Key('headerUserName'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

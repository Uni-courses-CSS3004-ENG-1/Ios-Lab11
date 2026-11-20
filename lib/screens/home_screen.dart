import 'package:flutter/material.dart';

import '../services/storage_service.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
        ],
      ),
    );
  }
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

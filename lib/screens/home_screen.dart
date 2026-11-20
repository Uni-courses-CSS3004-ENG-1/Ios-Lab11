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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes & Settings Vault')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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

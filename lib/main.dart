import 'package:flutter/material.dart';

import 'services/storage_service.dart';

Future<void> main() async {
  // Needed before any plugin call (SharedPreferences) that runs before runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Read the saved theme BEFORE the first frame. The very first frame is
  // already dark, so there is no white flash on a cold launch.
  final storage = await StorageService.init();

  runApp(VaultApp(storage: storage));
}

class VaultApp extends StatefulWidget {
  const VaultApp({super.key, required this.storage});

  final StorageService storage;

  @override
  State<VaultApp> createState() => _VaultAppState();
}

class _VaultAppState extends State<VaultApp> {
  // Filled synchronously from the pre-loaded storage, never `null`.
  late final bool _isDarkMode = widget.storage.loadDarkMode();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes & Settings Vault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const Scaffold(
        body: Center(child: Text('Notes & Settings Vault')),
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    if (options.apiKey.isNotEmpty) {
      await Firebase.initializeApp(options: options);
      firebaseReady = true;
    }
  } catch (_) {
    firebaseReady = false;
  }
  runApp(const IndusApp());
}

class IndusApp extends StatelessWidget {
  const IndusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (_, mode, __) => MaterialApp(
        title: 'Indus Virtual School',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: mode,
        home: const HomePage(),
      ),
    );
  }
}

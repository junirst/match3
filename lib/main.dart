import 'package:flutter/material.dart';
import 'opening_screen.dart';
import 'main_menu_screen.dart';
import 'audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize audio manager
  await AudioManager().init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Match 3 Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => OpeningScreen(),
        '/main_menu': (context) => MainMenuScreen(),
      },
    );
  }
}

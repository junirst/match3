import 'package:flutter/material.dart';
import 'opening_screen.dart';
import 'main_menu_screen.dart';
import 'ShopInside.dart';
import 'OutfitInside.dart';
import 'UpgradeInside.dart';
import 'SettingInside.dart';
import 'ChapterScreen.dart';
import 'Chapter1.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Match3 Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const OpeningScreen(),
        '/main_menu': (context) => const MainMenuScreen(),
        '/shop': (context) => const ShopScreen(),
        '/outfit': (context) => const OutfitScreen(),
        '/upgrade': (context) => const UpgradeScreen(),
        '/settings': (context) => const SettingScreen(),
        '/story': (context) => const Chapterscreen(),
        '/chapter1': (context) => const Chapter1Screen(),
      },
    );
  }
}

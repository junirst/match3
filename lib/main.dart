import 'package:flutter/material.dart';
import 'opening_screen.dart';
import 'main_menu_screen.dart';
import 'ShopInside.dart' as shop;
import 'OutfitInside.dart' as outfit;
import 'UpgradeInside.dart';
import 'SettingInside.dart';
import 'ChapterScreen.dart';
import 'Chapter1.dart';
import 'TowerMode.dart';
import 'player_profile.dart';

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
        '/shop': (context) => const shop.ShopScreen(),
        '/outfit': (context) => const outfit.OutfitScreen(),
        '/upgrade': (context) => const UpgradeScreen(),
        '/settings': (context) => const SettingScreen(),
        '/story': (context) => const Chapterscreen(),
        '/chapter1': (context) => const Chapter1Screen(),
        '/tower_mode': (context) => const TowerModeScreen(),
        '/player_profile': (context) => const PlayerProfileScreen(),
      },
    );
  }
}
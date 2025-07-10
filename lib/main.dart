import 'package:flutter/material.dart';
import 'opening_screen.dart';
import 'main_menu_screen.dart';
import 'ShopInside.dart';
import 'OutfitInside.dart';
import 'WeaponInside.dart';
import 'UpgradeInside.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const OpeningScreen(),
        '/main_menu': (context) => const MainMenuScreen(),
        '/shop': (context) => const ShopScreen(),
        '/outfit': (context) => const OutfitScreen(),
        '/weapon': (context) => const WeaponScreen(),
        '/upgrade': (context) => const UpgradeScreen(),
      },
    );
  }
}

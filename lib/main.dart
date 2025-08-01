import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/opening_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/ShopInside.dart' as shop;
import 'screens/OutfitInside.dart' as outfit;
import 'screens/UpgradeInside.dart';
import 'screens/SettingInside.dart';
import 'screens/ChapterScreen.dart';
import 'screens/Chapter1.dart';
import 'screens/TowerMode.dart';
import 'models/player_profile.dart';
import 'managers/audio_manager.dart';
import 'managers/game_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AudioManager
  await AudioManager().init();

  // Initialize GameManager
  await gameManager.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: gameManager,
      child: MaterialApp(
        title: 'Match3 Game',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: {
          '/': (context) => const OpeningScreen(),
          '/login': (context) => const LoginScreen(),
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
      ),
    );
  }
}

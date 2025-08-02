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

  // Start background music immediately after initialization
  await AudioManager().playBackgroundMusic();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Add observer to monitor app lifecycle
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove observer when app is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - ensure BGM is playing
        AudioManager().onAppResume();
        break;
      case AppLifecycleState.paused:
        // App went to background - stop all audio
        AudioManager().stopAllAudio();
        break;
      case AppLifecycleState.inactive:
        // App is inactive but still visible - pause audio
        AudioManager().onAppPause();
        break;
      case AppLifecycleState.detached:
        // App is detached - stop all audio and dispose
        AudioManager().stopAllAudio();
        AudioManager().dispose();
        break;
      case AppLifecycleState.hidden:
        // App is hidden - pause audio
        AudioManager().onAppPause();
        break;
    }
  }

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
        initialRoute: '/',
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

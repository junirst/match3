import 'package:flutter/material.dart';
import 'main_menu_screen.dart';
import 'ShopInside.dart';
import 'audio_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_manager.dart';

class OpeningScreen extends StatefulWidget {
  const OpeningScreen({super.key});

  @override
  _OpeningScreenState createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen>
    with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;
  String _currentLanguage = LanguageManager.currentLanguage;

  @override
  void initState() {
    super.initState();

    // Start background music
    AudioManager().playBackgroundMusic();

    _buttonController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _buttonAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
    _buttonController.forward();

    _loadLanguagePreference();
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('language') ?? 'English'; // Default to English
      LanguageManager.setLanguage(_currentLanguage);
    });
  }

  String _getLocalizedText(String englishText, String vietnameseText) {
    return _currentLanguage == 'Vietnamese' ? vietnameseText : englishText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          AudioManager().playSfx();
          Navigator.pushNamed(context, '/main_menu');
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Colors.grey[800],
              child: Image.asset(
                'assets/background.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.grey[800]);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Center(
                child: Image.asset(
                  'assets/logo.png',
                  width: 650,
                  height: 485,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 650,
                      height: 485,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 50.0),
                child: ScaleTransition(
                  scale: _buttonAnimation,
                  child: Text(
                    _getLocalizedText('PRESS TO CONTINUE', 'ẤN ĐỂ TIẾP TỤC'),
                    style: TextStyle(
                      fontFamily: 'Bungee',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(offset: Offset(-1, -1), color: Colors.black),
                        Shadow(offset: Offset(1, -1), color: Colors.black),
                        Shadow(offset: Offset(-1, 1), color: Colors.black),
                        Shadow(offset: Offset(1, 1), color: Colors.black),
                        Shadow(
                          offset: Offset(0, 0),
                          color: Colors.black,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
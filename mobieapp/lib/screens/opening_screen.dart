import 'package:flutter/material.dart';
import '../managers/audio_manager.dart';
import '../managers/language_manager.dart';
import 'dart:async';

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

    // Initialize audio (BGM already started in main.dart)
    _initAudio();

    _buttonController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _buttonAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
    _buttonController.forward();

    _loadLanguagePreference();
    // Removed _checkFirstLaunch() - no more popup needed
  }

  Future<void> _initAudio() async {
    try {
      // Ensure BGM is playing (it should already be started from main.dart)
      await AudioManager().ensureBgmPlaying();
      print('Audio ensured in OpeningScreen');
    } catch (e) {
      print('Error ensuring audio in OpeningScreen: $e');
    }
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _loadLanguagePreference() async {
    setState(() {
      _currentLanguage = LanguageManager.currentLanguage;
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
          // Navigate directly to login screen
          AudioManager().playButtonSound();
          Navigator.pushReplacementNamed(context, '/login');
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Container(
              color: Colors.grey[800],
              child: Image.asset(
                'assets/images/backgrounds/background.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.grey[800]);
                },
              ),
            ),

            // Logo
            Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Center(
                child: Image.asset(
                  'assets/images/ui/logo.png',
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

            // "Press to continue" text
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

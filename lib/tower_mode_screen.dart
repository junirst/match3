import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_manager.dart';
import 'language_manager.dart';

class TowerModeScreen extends StatefulWidget {
  const TowerModeScreen({super.key});

  @override
  _TowerModeScreenState createState() => _TowerModeScreenState();
}

class _TowerModeScreenState extends State<TowerModeScreen> {
  double _playScale = 1.0;
  double _leaderboardScale = 1.0;
  double _backScale = 1.0;

  String _currentLanguage = LanguageManager.currentLanguage;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('language') ?? 'English';
      LanguageManager.setLanguage(_currentLanguage);
    });
  }

  String _getLocalizedText(String englishText, String vietnameseText) {
    return _currentLanguage == 'Vietnamese' ? vietnameseText : englishText;
  }

  void _onButtonTap(String buttonName, Function setStateCallback) {
    AudioManager().playSfx();

    setState(() {
      switch (buttonName) {
        case 'play':
          _playScale = 1.1;
          break;
        case 'leaderboard':
          _leaderboardScale = 1.1;
          break;
        case 'back':
          _backScale = 1.1;
          break;
      }
    });
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _playScale = 1.0;
        _leaderboardScale = 1.0;
        _backScale = 1.0;
      });
      if (buttonName == 'back') {
        Navigator.pop(context);
      }
    });
  }

  Widget _buildMenuButton(
      String text,
      String buttonType,
      double scale,
      VoidCallback onTap,
      double screenWidth,
      double screenHeight,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: scale,
        duration: Duration(milliseconds: 100),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/frame.png',
              width: screenWidth * 0.8,
              height: screenHeight * 0.12,
            ),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Bungee',
                fontSize: screenWidth * 0.05,
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/tower_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.05),
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                _getLocalizedText('SEASON 0', 'MÙA 0'),
                style: TextStyle(
                  fontFamily: 'Bungee',
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(offset: Offset(1, 1), color: Colors.black, blurRadius: 2),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.12),
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                _getLocalizedText('RESET IN: 13 DAYS 4 HOURS', 'RESET TRONG: 13 NGÀY 4 GIỜ'),
                style: TextStyle(
                  fontFamily: 'Bungee',
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(offset: Offset(1, 1), color: Colors.black, blurRadius: 2),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMenuButton(
                  _getLocalizedText('PLAY', 'CHƠI'),
                  'play',
                  _playScale,
                      () => _onButtonTap('play', setState),
                  screenWidth,
                  screenHeight,
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  _getLocalizedText('RECORD: LEVEL 12', 'KỶ LỤC: CẤP 12'),
                  style: TextStyle(
                    fontFamily: 'Bungee',
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(offset: Offset(1, 1), color: Colors.black, blurRadius: 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.18),
              child: GestureDetector(
                onTap: () => _onButtonTap('leaderboard', setState),
                child: AnimatedScale(
                  scale: _leaderboardScale,
                  duration: Duration(milliseconds: 100),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/frame.png',
                        width: screenWidth * 0.5,
                        height: screenHeight * 0.1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/trophy.png',
                            width: screenWidth * 0.1,
                            height: screenHeight * 0.08,
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            _getLocalizedText('CHECK LEADERBOARD', 'KIỂM TRA BẢNG XẾP HẠNG'),
                            style: TextStyle(
                              fontFamily: 'Bungee',
                              fontSize: screenWidth * 0.04,
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: screenHeight * 0.03,
                right: screenWidth * 0.02,
              ),
              child: GestureDetector(
                onTap: () => _onButtonTap('back', setState),
                child: AnimatedScale(
                  scale: _backScale,
                  duration: Duration(milliseconds: 100),
                  child: Image.asset(
                    'assets/back_button.png',
                    width: screenWidth * 0.12,
                    height: screenHeight * 0.08,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
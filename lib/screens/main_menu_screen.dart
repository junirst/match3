import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../managers/audio_manager.dart';
import '../managers/language_manager.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  double _storyScale = 1.0;
  double _towerScale = 1.0;
  double _shopScale = 1.0;
  double _settingsScale = 1.0;
  double _playerScale = 1.0;
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
        case 'story':
          _storyScale = 1.1;
          break;
        case 'tower':
          _towerScale = 1.1;
          break;
        case 'shop':
          _shopScale = 1.1;
          break;
        case 'settings':
          _settingsScale = 1.1;
          break;
        case 'player':
          _playerScale = 1.1;
          break;
        case 'back':
          _backScale = 1.1;
          break;
      }
    });
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _storyScale = 1.0;
        _towerScale = 1.0;
        _shopScale = 1.0;
        _settingsScale = 1.0;
        _playerScale = 1.0;
        _backScale = 1.0;
      });
      if (buttonName == 'back') {
        Navigator.pushNamed(context, '/');
      } else if (buttonName == 'shop') {
        Navigator.pushNamed(context, '/shop');
      } else if (buttonName == 'settings') {
        Navigator.pushNamed(context, '/settings').then((_) {
          _loadLanguagePreference();
        });
      } else if (buttonName == 'player') {
        Navigator.pushNamed(context, '/player_profile');
      } else if (buttonName == 'story') {
        Navigator.pushNamed(context, '/story');
      } else if (buttonName == 'tower') {
        Navigator.pushNamed(context, '/tower_mode');
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
              'assets/images/ui/frame.png',
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
            color: Colors.grey[800],
            child: Image.asset(
              'assets/images/backgrounds/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.05),
            child: Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/images/ui/logo.png',
                width: screenWidth * 0.95,
                height: screenHeight * 0.25,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.02,
              left: screenWidth * 0.05,
            ),
            child: Text(
              _getLocalizedText('WELCOME BACK, PLAYER NAME', 'CHÀO MỪNG TRỞ LẠI, TÊN NGƯỜI CHƠI'),
              style: TextStyle(
                fontFamily: 'DistilleryDisplay',
                fontSize: screenWidth * 0.025,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    color: Colors.black,
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMenuButton(
                  _getLocalizedText('STORY MODE', 'CỐT TRUYỆN'),
                  'story',
                  _storyScale,
                      () => _onButtonTap('story', setState),
                  screenWidth,
                  screenHeight,
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildMenuButton(
                  _getLocalizedText('TOWER MODE', 'CHẾ ĐỘ THÁP'),
                  'tower',
                  _towerScale,
                      () => _onButtonTap('tower', setState),
                  screenWidth,
                  screenHeight,
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildMenuButton(
                  _getLocalizedText('SHOP', 'CỬA HÀNG'),
                  'shop',
                  _shopScale,
                      () => _onButtonTap('shop', setState),
                  screenWidth,
                  screenHeight,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _onButtonTap('player', setState),
                    child: AnimatedScale(
                      scale: _playerScale,
                      duration: Duration(milliseconds: 100),
                      child: Image.asset(
                        'assets/images/characters/player.png',
                        width: screenWidth * 0.25,
                        height: screenHeight * 0.08,
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.1),
                  GestureDetector(
                    onTap: () => _onButtonTap('settings', setState),
                    child: AnimatedScale(
                      scale: _settingsScale,
                      duration: Duration(milliseconds: 100),
                      child: Image.asset(
                        'assets/images/ui/settings_button.png',
                        width: screenWidth * 0.25,
                        height: screenHeight * 0.08,
                      ),
                    ),
                  ),
                ],
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
                    'assets/images/ui/back_button.png',
                    width: screenWidth * 0.18,
                    height: screenHeight * 0.18,
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
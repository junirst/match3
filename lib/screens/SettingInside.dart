import 'package:flutter/material.dart';
import '../managers/audio_manager.dart';
import 'audio_settings_screen.dart';
import 'LanguageInside.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../managers/language_manager.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  double _audioScale = 1.0;
  double _languageScale = 1.0;
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

  void _onButtonTap(String buttonName) {
    AudioManager().playButtonSound();

    setState(() {
      switch (buttonName) {
        case 'audio':
          _audioScale = 1.1;
          break;
        case 'language':
          _languageScale = 1.1;
          break;
        case 'back':
          _backScale = 1.1;
          break;
      }
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _audioScale = 1.0;
        _languageScale = 1.0;
        _backScale = 1.0;
      });

      if (buttonName == 'back') {
        Navigator.pop(context);
      } else if (buttonName == 'audio') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AudioSettingsScreen()),
        );
      } else if (buttonName == 'language') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LanguageScreen()),
        ).then((_) {
          // Refresh the language when returning from language screen
          _loadLanguagePreference();
        });
      }
    });
  }

  Widget _buildSettingButton(
    String englishText,
    String vietnameseText,
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
        duration: const Duration(milliseconds: 100),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/images/ui/frame.png',
              width: screenWidth * 0.8,
              height: screenHeight * 0.12,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.12,
                  color: Colors.grey,
                );
              },
            ),
            Text(
              _getLocalizedText(englishText, vietnameseText),
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

  Widget _buildSettingsHeader(double screenWidth, double screenHeight) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/images/ui/frame.png',
          width: screenWidth * 0.4,
          height: screenHeight * 0.08,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: screenWidth * 0.4,
              height: screenHeight * 0.08,
              color: Colors.grey,
            );
          },
        ),
        Text(
          _getLocalizedText('SETTINGS', 'CÀI ĐẶT'),
          style: TextStyle(
            fontFamily: 'Bungee',
            fontSize: screenWidth * 0.03,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(offset: Offset(-1, -1), color: Colors.black),
              Shadow(offset: Offset(1, -1), color: Colors.black),
              Shadow(offset: Offset(-1, 1), color: Colors.black),
              Shadow(offset: Offset(1, 1), color: Colors.black),
              Shadow(offset: Offset(0, 0), color: Colors.black, blurRadius: 2),
            ],
          ),
        ),
      ],
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
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey[800]);
              },
            ),
          ),
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.05,
            child: _buildSettingsHeader(screenWidth, screenHeight),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSettingButton(
                  'AUDIO',
                  'ÂM THANH',
                  'audio',
                  _audioScale,
                  () => _onButtonTap('audio'),
                  screenWidth,
                  screenHeight,
                ),
                SizedBox(height: screenHeight * 0.05),
                _buildSettingButton(
                  'LANGUAGE',
                  'NGÔN NGỮ',
                  'language',
                  _languageScale,
                  () => _onButtonTap('language'),
                  screenWidth,
                  screenHeight,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.03,
            right: screenWidth * 0.03,
            child: GestureDetector(
              onTap: () => _onButtonTap('back'),
              child: AnimatedScale(
                scale: _backScale,
                duration: const Duration(milliseconds: 100),
                child: Image.asset(
                  'assets/images/ui/backbutton.png',
                  width: screenWidth * 0.18,
                  height: screenHeight * 0.18,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: screenWidth * 0.12,
                      height: screenHeight * 0.08,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_manager.dart';
import 'language_manager.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  double _englishScale = 1.0;
  double _vietnameseScale = 1.0;
  double _backScale = 1.0;
  String _selectedLanguage = LanguageManager.currentLanguage;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? LanguageManager.currentLanguage;
      LanguageManager.setLanguage(_selectedLanguage);
    });
  }

  Future<void> _saveLanguagePreference(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    LanguageManager.setLanguage(language);
  }

  void _onButtonTap(String buttonName) {
    AudioManager().playSfx();

    setState(() {
      switch (buttonName) {
        case 'english':
          _englishScale = 1.1;
          break;
        case 'vietnamese':
          _vietnameseScale = 1.1;
          break;
        case 'back':
          _backScale = 1.1;
          break;
      }
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _englishScale = 1.0;
        _vietnameseScale = 1.0;
        _backScale = 1.0;
      });

      if (buttonName == 'back') {
        Navigator.pop(context);
      } else if (buttonName == 'english' && _selectedLanguage != 'English') {
        _showLanguageConfirmationDialog('English');
      } else if (buttonName == 'vietnamese' && _selectedLanguage != 'Vietnamese') {
        _showLanguageConfirmationDialog('Vietnamese');
      }
    });
  }

  void _showLanguageConfirmationDialog(String newLanguage) {
    String title = newLanguage == 'English' ? 'Change Language' : 'Thay đổi ngôn ngữ';
    String content = newLanguage == 'English'
        ? 'Are you sure you want to change the language to English?'
        : 'Bạn có chắc chắn muốn thay đổi ngôn ngữ sang Tiếng Việt?';
    String confirmText = newLanguage == 'English' ? 'Yes' : 'Có';
    String cancelText = newLanguage == 'English' ? 'Cancel' : 'Hủy';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'Bungee',
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          content: Text(
            content,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                cancelText,
                style: TextStyle(
                  color: Colors.red[300],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _selectedLanguage = newLanguage;
                });

                await _saveLanguagePreference(newLanguage);

                Navigator.of(context).pop();

                // Reset to OpeningScreen immediately
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                      (route) => false,
                );
              },
              child: Text(
                confirmText,
                style: TextStyle(
                  color: Colors.green[300],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageButton(String text, String buttonType, double scale, VoidCallback onTap, double screenWidth, double screenHeight, {bool isSelected = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 100),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/frame.png',
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
            if (isSelected)
              Positioned(
                right: screenWidth * 0.15,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: screenWidth * 0.06,
                  shadows: [
                    Shadow(offset: Offset(-1, -1), color: Colors.black),
                    Shadow(offset: Offset(1, -1), color: Colors.black),
                    Shadow(offset: Offset(-1, 1), color: Colors.black),
                    Shadow(offset: Offset(1, 1), color: Colors.black),
                  ],
                ),
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

  Widget _buildLanguageHeader(double screenWidth, double screenHeight) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/frame.png',
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
          'LANGUAGE',
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
              Shadow(
                offset: Offset(0, 0),
                color: Colors.black,
                blurRadius: 2,
              ),
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
              'assets/background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey[800]);
              },
            ),
          ),
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.05,
            child: _buildLanguageHeader(screenWidth, screenHeight),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLanguageButton(
                  'ENGLISH',
                  'english',
                  _englishScale,
                      () => _onButtonTap('english'),
                  screenWidth,
                  screenHeight,
                  isSelected: _selectedLanguage == 'English',
                ),
                SizedBox(height: screenHeight * 0.05),
                _buildLanguageButton(
                  'TIẾNG VIỆT',
                  'vietnamese',
                  _vietnameseScale,
                      () => _onButtonTap('vietnamese'),
                  screenWidth,
                  screenHeight,
                  isSelected: _selectedLanguage == 'Vietnamese',
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
                  'assets/backbutton.png',
                  width: screenWidth * 0.12,
                  height: screenHeight * 0.08,
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
import 'package:flutter/material.dart';
import 'audio_manager.dart';

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
  double _backScale = 1.0;

  void _onButtonTap(String buttonName, Function setStateCallback) {
    // Play sound effect
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
        _backScale = 1.0;
      });
      if (buttonName == 'back') {
        Navigator.pushNamed(context, '/');
      } else if (buttonName == 'shop') {
        Navigator.pushNamed(context, '/shop');
      }
    });
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
          // Placeholder for background image
          Container(
            color: Colors.grey[800],
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey[800]); // Fallback
              },
            ),
          ),
          // Logo placeholder in top center
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.05),
            child: Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/logo.png',
                width: screenWidth * 0.8,
                height: screenHeight * 0.15,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: screenWidth * 0.2,
                    height: screenHeight * 0.1,
                    color: Colors.grey, // Fallback
                  );
                },
              ),
            ),
          ),
          // Welcome text in top-left with Distillery Display font
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.02,
              left: screenWidth * 0.05,
            ),
            child: Text(
              'WELCOME BACK, PLAYER NAME',
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
          // Buttons with pop animation using PNG placeholders
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _onButtonTap('story', setState),
                  child: AnimatedScale(
                    scale: _storyScale,
                    duration: Duration(milliseconds: 100),
                    child: Image.asset(
                      'assets/story_button.png', // Placeholder for Story Mode PNG
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.08,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: screenWidth * 0.4,
                          height: screenHeight * 0.06,
                          color: Colors.grey, // Fallback
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                GestureDetector(
                  onTap: () => _onButtonTap('tower', setState),
                  child: AnimatedScale(
                    scale: _towerScale,
                    duration: Duration(milliseconds: 100),
                    child: Image.asset(
                      'assets/tower_button.png', // Placeholder for Tower Mode PNG
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.08,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: screenWidth * 0.4,
                          height: screenHeight * 0.06,
                          color: Colors.grey, // Fallback
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                GestureDetector(
                  onTap: () => _onButtonTap('shop', setState),
                  child: AnimatedScale(
                    scale: _shopScale,
                    duration: Duration(milliseconds: 100),
                    child: Image.asset(
                      'assets/shop_button.png', // Placeholder for Shop PNG
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.08,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: screenWidth * 0.4,
                          height: screenHeight * 0.06,
                          color: Colors.grey, // Fallback
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Settings button with PNG
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.18),
              child: GestureDetector(
                onTap: () => _onButtonTap('settings', setState),
                child: AnimatedScale(
                  scale: _settingsScale,
                  duration: Duration(milliseconds: 100),
                  child: Image.asset(
                    'assets/settings_button.png', // Placeholder for Settings PNG
                    width: screenWidth * 0.25,
                    height: screenHeight * 0.08,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: screenWidth * 0.15,
                        height: screenHeight * 0.06,
                        color: Colors.grey, // Fallback
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // Back button with PNG
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
                    'assets/back_button.png', // Placeholder for Back PNG
                    width: screenWidth * 0.12,
                    height: screenHeight * 0.08,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: screenWidth * 0.1,
                        height: screenHeight * 0.06,
                        color: Colors.grey, // Fallback
                      );
                    },
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

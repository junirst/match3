import 'package:flutter/material.dart';

class MainMenuScreen extends StatefulWidget {
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            padding: EdgeInsets.only(top: 40),
            child: Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/logo.png',
                width: 1250,
                height: 250,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey, // Fallback
                  );
                },
              ),
            ),
          ),
          // Welcome text in top-left with Distillery Display font
          Padding(
            padding: EdgeInsets.only(top: 16.0, left: 120.0), // Right of logo
            child: Text(
              'WELCOME BACK, PLAYER NAME',
              style: TextStyle(
                fontFamily: 'DistilleryDisplay',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(offset: Offset(1, 1), color: Colors.black, blurRadius: 2),
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
                      width: 700,
                      height: 125,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 60,
                          color: Colors.grey, // Fallback
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _onButtonTap('tower', setState),
                  child: AnimatedScale(
                    scale: _towerScale,
                    duration: Duration(milliseconds: 100),
                    child: Image.asset(
                      'assets/tower_button.png', // Placeholder for Tower Mode PNG
                      width: 700,
                      height: 125,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 60,
                          color: Colors.grey, // Fallback
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _onButtonTap('shop', setState),
                  child: AnimatedScale(
                    scale: _shopScale,
                    duration: Duration(milliseconds: 100),
                    child: Image.asset(
                      'assets/shop_button.png', // Placeholder for Shop PNG
                      width: 700,
                      height: 125,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 60,
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
              padding: EdgeInsets.only(right: 0.0, top: 30.0, bottom: 150.0),
              child: GestureDetector(
                onTap: () => _onButtonTap('settings', setState),
                child: AnimatedScale(
                  scale: _settingsScale,
                  duration: Duration(milliseconds: 100),
                  child: Image.asset(
                    'assets/settings_button.png', // Placeholder for Settings PNG
                    width: 300,
                    height: 125,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
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
              padding: EdgeInsets.only(bottom: 20.0, right: 10, left: 80),
              child: GestureDetector(
                onTap: () => _onButtonTap('back', setState),
                child: AnimatedScale(
                  scale: _backScale,
                  duration: Duration(milliseconds: 100),
                  child: Image.asset(
                    'assets/back_button.png', // Placeholder for Back PNG
                    width: 150,
                    height: 125,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
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
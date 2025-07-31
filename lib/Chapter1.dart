import 'package:flutter/material.dart';
import 'audio_manager.dart';
import 'GameplayScreen.dart';
import 'language_manager.dart';

class Chapter1Screen extends StatefulWidget {
  const Chapter1Screen({super.key});

  @override
  _Chapter1ScreenState createState() => _Chapter1ScreenState();
}

class _Chapter1ScreenState extends State<Chapter1Screen> {
  double _backScale = 1.0;

  @override
  void initState() {
    super.initState();
    LanguageManager.initializeLanguage();
  }

  void _onButtonTap(String buttonName) {
    // Play sound effect
    AudioManager().playSfx();

    setState(() {
      switch (buttonName) {
        case 'back':
          _backScale = 1.1;
          break;
      }
    });

    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _backScale = 1.0;
      });

      if (buttonName == 'back') {
        Navigator.pop(context);
      }
    });
  }

  void _onLevelTap(int levelNumber) {
    // Play sound effect
    AudioManager().playSfx();

    // Show level popup dialog
    _showLevelDialog(levelNumber);
  }

  void _showLevelDialog(int levelNumber) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;
        final screenWidth = screenSize.width;
        final screenHeight = screenSize.height;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: screenWidth * 0.8,
            height: screenHeight * 0.5,
            decoration: BoxDecoration(
              color: Colors.brown[800], // Changed from Colors.brown[100] to darker brown
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.brown[900]!, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Level title - Localized
                Text(
                  '${LanguageManager.getText('level')} 1.$levelNumber',
                  style: TextStyle(
                    fontFamily: 'Bungee',
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(offset: Offset(-1, -1), color: Colors.black),
                      Shadow(offset: Offset(1, -1), color: Colors.black),
                      Shadow(offset: Offset(-1, 1), color: Colors.black),
                      Shadow(offset: Offset(1, 1), color: Colors.black),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // Play button - UPDATED TO NAVIGATE TO GAMEPLAYSCREEN
                GestureDetector(
                  onTap: () {
                    AudioManager().playSfx();
                    Navigator.pop(context); // Close the dialog first
                    // Navigate to GameplayScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GameplayScreen(chapter: 1, level: levelNumber),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/PlayButton.png',
                    width: screenWidth * 0.3,
                    height: screenHeight * 0.12,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: screenWidth * 0.3,
                        height: screenHeight * 0.12,
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.green[800]!,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            LanguageManager.getText('play'),
                            style: TextStyle(
                              fontFamily: 'Bungee',
                              color: Colors.white,
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
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
                      );
                    },
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // Reward section - Localized
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${LanguageManager.getText('reward')} ${levelNumber * 50}',
                      style: TextStyle(
                        fontFamily: 'Bungee',
                        fontSize: screenWidth * 0.05,
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
                    SizedBox(width: 8),
                    // Gold coin icon
                    Container(
                      width: screenWidth * 0.08,
                      height: screenWidth * 0.08,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.orange[800]!,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 2,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.monetization_on,
                        color: Colors.orange[800],
                        size: screenWidth * 0.09,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChapter1Header(double screenWidth, double screenHeight) {
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
          LanguageManager.getText('chapter_1'),
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
    );
  }

  Widget _buildLevelButton(
      int levelNumber,
      double screenWidth,
      double screenHeight,
      ) {
    return GestureDetector(
      onTap: () => _onLevelTap(levelNumber),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/roundframe.png',
            width: screenWidth * 0.15,
            height: screenWidth * 0.15,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                decoration: BoxDecoration(
                  color: Colors.orange[600],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.brown[800]!, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              );
            },
          ),
          Text(
            levelNumber.toString(),
            style: TextStyle(
              fontFamily: 'Bungee',
              color: Colors.white,
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(offset: Offset(-1, -1), color: Colors.black),
                Shadow(offset: Offset(1, -1), color: Colors.black),
                Shadow(offset: Offset(-1, 1), color: Colors.black),
                Shadow(offset: Offset(1, 1), color: Colors.black),
              ],
            ),
          ),
        ],
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
          // Background map image
          Container(
            color: Colors.brown[200],
            child: Image.asset(
              'assets/Chapter1background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.brown[200],
                  child: Center(
                    child: Text(
                      '${LanguageManager.getText('chapter')} 1 Map',
                      style: TextStyle(
                        fontFamily: 'Bungee',
                        color: Colors.brown[800],
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
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
                );
              },
            ),
          ),

          // Chapter 1 title in top left using frame - Localized
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.05,
            child: _buildChapter1Header(screenWidth, screenHeight),
          ),

          // Level selection points (positioned across the map)
          // Level 1 - Bottom center (starting point)
          Positioned(
            top: screenHeight * 0.85,
            left: screenWidth * 0.25,
            child: _buildLevelButton(1, screenWidth, screenHeight),
          ),

          // Level 2 - Center-left
          Positioned(
            top: screenHeight * 0.60,
            left: screenWidth * 0.25,
            child: _buildLevelButton(2, screenWidth, screenHeight),
          ),

          // Level 3 - Middle right
          Positioned(
            top: screenHeight * 0.47,
            left: screenWidth * 0.27,
            child: _buildLevelButton(3, screenWidth, screenHeight),
          ),

          // Level 4 - Top center-right
          Positioned(
            top: screenHeight * 0.35,
            left: screenWidth * 0.55,
            child: _buildLevelButton(4, screenWidth, screenHeight),
          ),

          // Level 5 - Top left area (final level)
          Positioned(
            top: screenHeight * 0.23,
            left: screenWidth * 0.15,
            child: _buildLevelButton(5, screenWidth, screenHeight),
          ),

          // Back button in bottom right
          Positioned(
            bottom: screenHeight * 0.03,
            right: screenWidth * 0.03,
            child: GestureDetector(
              onTap: () => _onButtonTap('back'),
              child: AnimatedScale(
                scale: _backScale,
                duration: Duration(milliseconds: 100),
                child: Image.asset(
                  'assets/back_button.png',
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
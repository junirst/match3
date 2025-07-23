import 'package:flutter/material.dart';
import 'audio_manager.dart';
import 'GameplayScreen.dart';

class Chapter1Screen extends StatefulWidget {
  const Chapter1Screen({super.key});

  @override
  _Chapter1ScreenState createState() => _Chapter1ScreenState();
}

class _Chapter1ScreenState extends State<Chapter1Screen> {
  double _backScale = 1.0;

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
              color: Colors.brown[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.brown[800]!, width: 4),
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
                // Level title
                Text(
                  'Level 1.$levelNumber',
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
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
                            'PLAY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // Reward section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Reward: ${levelNumber * 50}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[700],
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
                        size: screenWidth * 0.05,
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
                      'Chapter 1 Map',
                      style: TextStyle(
                        color: Colors.brown[800],
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Chapter 1 title in top left
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.05,
            child: Image.asset(
              'assets/Chapter1.png',
              width: screenWidth * 0.25,
              height: screenHeight * 0.08,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: screenWidth * 0.25,
                  height: screenHeight * 0.08,
                  decoration: BoxDecoration(
                    color: Colors.brown[600],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange, width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      'CHAPTER 1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Level selection points (positioned across the map)
          // Level 1 - Top left area
          Positioned(
            top: screenHeight * 0.2,
            left: screenWidth * 0.2,
            child: _buildLevelButton(1, screenWidth, screenHeight),
          ),

          // Level 2 - Middle left
          Positioned(
            top: screenHeight * 0.35,
            left: screenWidth * 0.15,
            child: _buildLevelButton(2, screenWidth, screenHeight),
          ),

          // Level 3 - Center
          Positioned(
            top: screenHeight * 0.4,
            left: screenWidth * 0.45,
            child: _buildLevelButton(3, screenWidth, screenHeight),
          ),

          // Level 4 - Right side
          Positioned(
            top: screenHeight * 0.3,
            right: screenWidth * 0.2,
            child: _buildLevelButton(4, screenWidth, screenHeight),
          ),

          // Level 5 - Bottom center
          Positioned(
            bottom: screenHeight * 0.25,
            left: screenWidth * 0.4,
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

  Widget _buildLevelButton(
    int levelNumber,
    double screenWidth,
    double screenHeight,
  ) {
    return GestureDetector(
      onTap: () => _onLevelTap(levelNumber),
      child: Container(
        width: screenWidth * 0.12,
        height: screenWidth * 0.12,
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
        child: Center(
          child: Text(
            levelNumber.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

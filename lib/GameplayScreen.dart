import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'dart:math';
import 'audio_manager.dart';
import 'flame_match3_game.dart'; // Add this import

class GameplayScreen extends StatefulWidget {
  final int chapter;
  final int level;

  const GameplayScreen({super.key, required this.chapter, required this.level});

  @override
  _GameplayScreenState createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  bool _isPaused = false;
  late Match3Game game;

  @override
  void initState() {
    super.initState();
    game = Match3Game();
  }

  void _onPausePressed() {
    AudioManager().playSfx();
    setState(() {
      _isPaused = !_isPaused;
    });

    if (_isPaused) {
      game.paused = true;
      _showPauseDialog();
    }
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;
        final screenWidth = screenSize.width;
        final screenHeight = screenSize.height;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: screenWidth * 0.8,
            height: screenHeight * 0.4,
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
                Text(
                  'PAUSED',
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Resume button
                    GestureDetector(
                      onTap: () {
                        AudioManager().playSfx();
                        setState(() {
                          _isPaused = false;
                        });
                        game.paused = false;
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: screenWidth * 0.2,
                        height: screenHeight * 0.08,
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
                            'RESUME',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Exit button
                    GestureDetector(
                      onTap: () {
                        AudioManager().playSfx();
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Exit to previous screen
                      },
                      child: Container(
                        width: screenWidth * 0.2,
                        height: screenHeight * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.red[800]!, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            'EXIT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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

  Widget _buildGameGrid(double screenWidth, double screenHeight) {
    // Use responsive sizing that fits available space
    double gridSize = screenWidth * 0.85;

    return Container(
      width: gridSize,
      height: gridSize,
      decoration: BoxDecoration(
        color: Colors.brown[700]!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.brown[800]!, width: 3),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: GameWidget<Match3Game>.controlled(gameFactory: () => game),
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
          // Single background image covering entire screen
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Gameplaybg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Fallback background if image fails to load
          Container(
            color: Colors.brown[200],
            child: Image.asset(
              'assets/Gameplaybg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.lightGreen[200]!, Colors.brown[400]!],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Gameplay Background',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Goblin image for level 1.1 and 1.2 (BEHIND sword hand)
          if (widget.chapter == 1 && (widget.level == 1 || widget.level == 2))
            Positioned(
              left:
                  screenWidth * 0.5 -
                  (screenWidth * 0.15), // Center horizontally
              top:
                  screenHeight *
                  0.1, // Position in the middle-upper area of the nature background
              child: Image.asset(
                'assets/Mobs/Goblin.png',
                width: screenWidth * 0.3,
                height: screenWidth * 0.3,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading Goblin image: $error');
                  return Container(
                    width: screenWidth * 0.3,
                    height: screenWidth * 0.3,
                    decoration: BoxDecoration(
                      color: Colors.green[400],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green[700]!, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          size: screenWidth * 0.1,
                          color: Colors.green[700],
                        ),
                        Text(
                          'GOBLIN',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Ghost image for level 1.3 and 1.4 (BEHIND sword hand)
          if (widget.chapter == 1 && (widget.level == 3 || widget.level == 4))
            Positioned(
              left:
                  screenWidth * 0.5 -
                  (screenWidth * 0.15), // Center horizontally (same as Goblin)
              top: screenHeight * 0.1, // Same position as Goblin
              child: Image.asset(
                'assets/Mobs/Ghost.png',
                width: screenWidth * 0.3,
                height: screenWidth * 0.3,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading Ghost image: $error');
                  return Container(
                    width: screenWidth * 0.3,
                    height: screenWidth * 0.3,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[700]!, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.visibility_off,
                          size: screenWidth * 0.1,
                          color: Colors.grey[700],
                        ),
                        Text(
                          'GHOST',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Dragon image for level 1.5 (BEHIND sword hand)
          if (widget.chapter == 1 && widget.level == 5)
            Positioned(
              left:
                  screenWidth * 0.5 -
                  (screenWidth * 0.35), // Adjusted for much bigger size
              top: screenHeight * 0.04, // Moved up more for bigger dragon
              child: Image.asset(
                'assets/Mobs/Dragon.png',
                width: screenWidth * 0.7, // Much bigger - 70% of screen width
                height: screenWidth * 0.7, // Much bigger - 70% of screen width
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading Dragon image: $error');
                  return Container(
                    width: screenWidth * 0.7, // Much bigger
                    height: screenWidth * 0.7, // Much bigger
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.red[700]!, width: 3),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.whatshot,
                          size: screenWidth * 0.2, // Much bigger icon
                          color: Colors.red[700],
                        ),
                        Text(
                          'DRAGON',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: screenWidth * 0.06, // Much bigger text
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Sword hand image positioned ABOVE all mobs (in the foreground)
          Positioned(
            right: screenWidth * 0.02,
            top: screenHeight * 0.15, // Moved higher up
            bottom: screenHeight * 0.55, // Adjusted to be above wooden area
            child: Image.asset(
              'assets/SwordHand.png',
              width: screenWidth * 0.2,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: screenWidth * 0.2,
                  height: screenHeight * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.brown[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.sports_martial_arts,
                    size: screenWidth * 0.1,
                    color: Colors.brown[600],
                  ),
                );
              },
            ),
          ),

          // Main content using Column layout
          SafeArea(
            child: Column(
              children: [
                // Top UI Bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Level indicator on the left
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.brown[600],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Level ${widget.chapter}.${widget.level}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Pause button on the right
                      GestureDetector(
                        onTap: _onPausePressed,
                        child: Container(
                          width: screenWidth * 0.12,
                          height: screenWidth * 0.12,
                          decoration: BoxDecoration(
                            color: Colors.brown[600],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.orange, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/PauseButton.png',
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.pause,
                                color: Colors.white,
                                size: screenWidth * 0.06,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Flexible space for the game grid
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: screenWidth * 0.05,
                        right: screenWidth * 0.05,
                        top: screenWidth * 0.57,
                        bottom: screenWidth * 0.02,
                      ),
                      child: _buildGameGrid(screenWidth, screenHeight),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

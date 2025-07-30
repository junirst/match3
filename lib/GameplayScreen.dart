import 'package:flutter/material.dart';
import 'package:flame/game.dart';
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

  // Enemy health system - Initialize with default values
  int maxEnemyHealth = 100;
  int currentEnemyHealth = 100;

  // Power/Gold bar system
  int maxPowerPoints = 50;
  int currentPowerPoints = 0;
  static const int starPowerGain = 5;
  static const int powerAttackDamage = 50;

  // Damage values for different tile types
  static const int swordDamage = 10;

  @override
  void initState() {
    super.initState();

    // Set enemy health based on enemy type
    _initializeEnemyHealth();

    game = Match3Game();

    // Set up callback for when matches occur
    game.onMatchCallback = _handleMatch;
  }

  void _initializeEnemyHealth() {
    // Set health based on enemy type
    if (widget.chapter == 1) {
      if (widget.level == 1 || widget.level == 2) {
        // Goblin
        maxEnemyHealth = 100;
      } else if (widget.level == 3 || widget.level == 4) {
        // Ghost
        maxEnemyHealth = 150;
      } else if (widget.level == 5) {
        // Dragon (boss)
        maxEnemyHealth = 300;
      } else {
        maxEnemyHealth = 100; // Default
      }
    } else {
      maxEnemyHealth = 100; // Default for other chapters
    }

    currentEnemyHealth = maxEnemyHealth;

    // Reset power bar at start of each level
    currentPowerPoints = 0;
  }

  void _handleMatch(int tileType, int matchCount) {
    // Ensure widget is still mounted before updating state
    if (!mounted) return;

    setState(() {
      switch (tileType) {
        case 0: // Sword - deals damage
          int damage =
              swordDamage * (matchCount ~/ 3); // Base damage per set of 3
          if (matchCount > 3) {
            // Bonus damage for longer matches
            damage += (matchCount - 3) * 2;
          }
          currentEnemyHealth = (currentEnemyHealth - damage).clamp(
            0,
            maxEnemyHealth,
          );
          print(
            'Sword match! Dealt $damage damage. Enemy health: $currentEnemyHealth/$maxEnemyHealth',
          );

          // Check if enemy is defeated
          if (currentEnemyHealth <= 0) {
            _onEnemyDefeated();
          }
          break;
        case 1: // Shield - could add defense bonus later
          print('Shield match! (No effect yet)');
          break;
        case 2: // Heart - could heal player later
          print('Heart match! (No effect yet)');
          break;
        case 3: // Star - adds power points
          int powerGain =
              starPowerGain * (matchCount ~/ 3); // Base power per set of 3
          if (matchCount > 3) {
            // Bonus power for longer matches
            powerGain += (matchCount - 3) * 2;
          }
          currentPowerPoints = (currentPowerPoints + powerGain).clamp(
            0,
            maxPowerPoints,
          );
          print(
            'Star match! Gained $powerGain power. Power: $currentPowerPoints/$maxPowerPoints',
          );
          break;
      }
    });
  }

  void _onPowerBarClicked() {
    // Only allow power attack if bar is full
    if (currentPowerPoints >= maxPowerPoints) {
      AudioManager().playSfx();

      setState(() {
        // Deal power attack damage
        currentEnemyHealth = (currentEnemyHealth - powerAttackDamage).clamp(
          0,
          maxEnemyHealth,
        );

        // Reset power bar
        currentPowerPoints = 0;

        print(
          'Power attack! Dealt $powerAttackDamage damage. Enemy health: $currentEnemyHealth/$maxEnemyHealth',
        );

        // Check if enemy is defeated
        if (currentEnemyHealth <= 0) {
          _onEnemyDefeated();
        }
      });
    } else {
      print(
        'Power bar not full yet. Need ${maxPowerPoints - currentPowerPoints} more power.',
      );
    }
  }

  void _onEnemyDefeated() {
    print('Enemy defeated!');
    // TODO: Add victory logic, move to next level, etc.
    AudioManager().playSfx();

    // Show victory dialog or navigate to next level
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green[800]!, width: 4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'VICTORY!',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    AudioManager().playSfx();
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Return to previous screen
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.green[600],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.green[800]!, width: 3),
                    ),
                    child: Text(
                      'CONTINUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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

          SafeArea(
            child: Column(
              children: [
                // Top UI Bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.01, // Reduced from 0.02
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Level indicator
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

                      // Pause button
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

                // Main content area
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                    ),
                    child: Column(
                      children: [
                        // Enemy area with fixed height for consistency
                        Container(
                          height:
                              screenHeight *
                              0.35, // Reduced from 0.4 to move bars up
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Enemy image and health bar
                              if (widget.chapter == 1 &&
                                  (widget.level == 1 || widget.level == 2))
                                _buildEnemyWidget(
                                  'assets/Mobs/Goblin.png',
                                  Colors.green,
                                  'GOBLIN',
                                  screenWidth,
                                  screenHeight,
                                ),
                              if (widget.chapter == 1 &&
                                  (widget.level == 3 || widget.level == 4))
                                _buildEnemyWidget(
                                  'assets/Mobs/Ghost.png',
                                  Colors.grey,
                                  'GHOST',
                                  screenWidth,
                                  screenHeight,
                                ),
                              if (widget.chapter == 1 && widget.level == 5)
                                _buildEnemyWidget(
                                  'assets/Mobs/Dragon.png',
                                  Colors.red,
                                  'DRAGON',
                                  screenWidth,
                                  screenHeight,
                                  isDragon: true,
                                ),
                            ],
                          ),
                        ),

                        // Small spacing before wooden area
                        SizedBox(height: screenHeight * 0.03),

                        // Player health and power bars (positioned near wooden border)
                        _buildPlayerBars(screenWidth, screenHeight),

                        // Spacing between bars and game grid
                        SizedBox(height: screenHeight * 0.03),

                        // Game grid (positioned in wooden area)
                        Container(
                          height:
                              screenHeight * 0.32, // Slightly increased height
                          child: _buildGameGrid(screenWidth, screenHeight),
                        ),

                        // Bottom padding within wooden area
                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sword hand image (positioned above all)
          Positioned(
            right: screenWidth * 0.02,
            top: screenHeight * 0.15,
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
        ],
      ),
    );
  }

  // Helper method for enemy widget
  Widget _buildEnemyWidget(
    String assetPath,
    Color baseColor,
    String label,
    double screenWidth,
    double screenHeight, {
    bool isDragon = false,
  }) {
    // Define approximate 400 and 700 shades manually
    Color lightShade = baseColor == Colors.green
        ? Color.fromRGBO(200, 230, 201, 1.0)
        : // Green 400
          baseColor == Colors.grey
        ? Color.fromRGBO(189, 189, 189, 1.0)
        : // Grey 400
          Color.fromRGBO(255, 205, 210, 1.0); // Red 400
    Color darkShade = baseColor == Colors.green
        ? Color.fromRGBO(76, 175, 80, 1.0)
        : // Green 700
          baseColor == Colors.grey
        ? Color.fromRGBO(117, 117, 117, 1.0)
        : // Grey 700
          Color.fromRGBO(229, 115, 115, 1.0); // Red 700

    return Column(
      children: [
        // Health bar with actual health percentage
        Container(
          width: isDragon ? screenWidth * 0.5 : screenWidth * 0.25,
          height: screenHeight * 0.015,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Stack(
            children: [
              // Health bar fill
              Container(
                width:
                    (isDragon ? screenWidth * 0.5 : screenWidth * 0.25) *
                    (currentEnemyHealth / maxEnemyHealth),
                decoration: BoxDecoration(
                  color: currentEnemyHealth > maxEnemyHealth * 0.5
                      ? Colors.green
                      : currentEnemyHealth > maxEnemyHealth * 0.25
                      ? Colors.orange
                      : Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // Health text overlay
              Center(
                child: Text(
                  '$currentEnemyHealth/$maxEnemyHealth',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.02,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.005), // Reduced spacing
        Image.asset(
          assetPath,
          width: isDragon
              ? screenWidth * 0.6
              : screenWidth * 0.3, // Slightly smaller dragon
          height: isDragon
              ? screenWidth * 0.4
              : screenWidth * 0.3, // Slightly smaller dragon
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading $label image: $error');
            return Container(
              width: isDragon ? screenWidth * 0.6 : screenWidth * 0.3,
              height: isDragon ? screenWidth * 0.4 : screenWidth * 0.3,
              decoration: BoxDecoration(
                color: lightShade,
                borderRadius: BorderRadius.circular(isDragon ? 15 : 10),
                border: Border.all(color: darkShade, width: isDragon ? 3 : 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isDragon
                        ? Icons.whatshot
                        : (label == 'GHOST'
                              ? Icons.visibility_off
                              : Icons.person),
                    size: isDragon
                        ? screenWidth * 0.15
                        : screenWidth * 0.1, // Slightly smaller
                    color: darkShade,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: darkShade,
                      fontSize: isDragon
                          ? screenWidth *
                                0.05 // Slightly smaller
                          : screenWidth * 0.03,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGameGrid(double screenWidth, double screenHeight) {
    double gridSize = screenWidth * 0.75; // Increased back to 75%
    return Container(
      width: gridSize,
      height: gridSize, // Make it square to fit 5x5 properly
      child: GameWidget<Match3Game>.controlled(gameFactory: () => game),
    );
  }

  Widget _buildPlayerBars(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.75,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HEALTH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Container(
                  height: screenHeight * 0.02,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POWER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                GestureDetector(
                  onTap: _onPowerBarClicked,
                  child: Container(
                    height: screenHeight * 0.02,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Stack(
                      children: [
                        // Power bar fill
                        Container(
                          width:
                              (screenWidth * 0.75 * 0.5 - screenWidth * 0.03) *
                              (currentPowerPoints / maxPowerPoints),
                          decoration: BoxDecoration(
                            color: currentPowerPoints >= maxPowerPoints
                                ? Colors.orange[600] // Full - ready to use
                                : Colors.yellow[600], // Filling up
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        // Power text overlay
                        Center(
                          child: Text(
                            '$currentPowerPoints/$maxPowerPoints',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.02,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Visual indicator when full
                        if (currentPowerPoints >= maxPowerPoints)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.orange,
                                width: 2,
                              ),
                            ),
                          ),
                      ],
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

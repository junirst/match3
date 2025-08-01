import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../managers/audio_manager.dart';
import '../core/flame_match3_game.dart';

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

  // Player health system
  int maxPlayerHealth = 100;
  int currentPlayerHealth = 100;
  int excessHealth = 0; // Store excess health beyond max

  // Power/Gold bar system
  int maxPowerPoints = 50;
  int currentPowerPoints = 0;
  static const int starPowerGain = 5;
  static const int powerAttackDamage = 50;

  // Damage values for different tile types
  static const int swordDamage = 10;
  static const int heartHeal = 5;

  // Turn-based system
  bool isPlayerTurn = true;
  bool isProcessingTurn = false;

  // Weapon system
  String _equippedWeapon = 'Sword';
  final Map<String, String> _weaponAssets = {
    'Sword': 'assets/images/items/SwordHand.png',
    'Dagger': 'assets/images/items/Dagger.png',
    'Hand': 'assets/images/items/Hand.png',
  };

  @override
  void initState() {
    super.initState();

    // Load equipped weapon
    _loadEquippedWeapon();

    // Set enemy health based on enemy type
    _initializeEnemyHealth();

    game = Match3Game();

    // Set up callback for when matches occur
    game.onMatchCallback = _handleMatch;

    // Set up callback for when all cascading matches are complete
    game.onAllMatchesCompleteCallback = _onAllMatchesComplete;

    // Initialize game turn state
    game.setPlayerTurn(isPlayerTurn);
    game.setProcessingTurn(isProcessingTurn);
  }

  Future<void> _loadEquippedWeapon() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _equippedWeapon = prefs.getString('equipped_weapon') ?? 'Sword';
    });
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

  void _handleMatch(int tileType, int matchCount, int score) {
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

          // Check if enemy is defeated immediately (don't wait for turn end)
          if (currentEnemyHealth <= 0) {
            Future.delayed(Duration(milliseconds: 500), () {
              if (mounted) {
                _onEnemyDefeated();
              }
            });
            return;
          }
          break;
        case 1: // Shield - could add defense bonus later
          print('Shield match! (No effect yet)');
          break;
        case 2: // Heart - heals player
          int healing =
              heartHeal * (matchCount ~/ 3); // Base healing per set of 3
          if (matchCount > 3) {
            // Bonus healing for longer matches
            healing += (matchCount - 3) * 2;
          }

          // Calculate actual healing and excess
          int missingHealth = maxPlayerHealth - currentPlayerHealth;
          int actualHealing = healing.clamp(0, missingHealth);
          int excess = healing - actualHealing;

          currentPlayerHealth += actualHealing;
          excessHealth += excess;

          print(
            'Heart match! Healed $actualHealing HP (${excess > 0 ? '+$excess excess' : 'no excess'}). Player health: $currentPlayerHealth/$maxPlayerHealth${excessHealth > 0 ? ' (+$excessHealth)' : ''}',
          );
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

    // NOTE: Turn switching moved to _onAllMatchesComplete to wait for all cascades
  }

  // Called when all cascading matches are complete - this is when we should end the player's turn
  void _onAllMatchesComplete() {
    print('All matches complete! Checking if player turn should end...');

    // Only end turn if enemy is still alive and it's still the player's turn
    if (currentEnemyHealth > 0 && isPlayerTurn && !isProcessingTurn) {
      _checkEndPlayerTurn();
    }
  }

  // Check if player turn should end and trigger mob turn
  void _checkEndPlayerTurn() {
    if (!isPlayerTurn || isProcessingTurn) return;

    print('Ending player turn after all matches completed...');

    // Shorter delay since all matches are already complete
    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted && isPlayerTurn && !isProcessingTurn) {
        _endPlayerTurn();
      }
    });
  }

  void _endPlayerTurn() {
    if (!isPlayerTurn || isProcessingTurn) return;

    setState(() {
      isPlayerTurn = false;
      isProcessingTurn = true;
    });

    // Sync with game
    game.setPlayerTurn(false);
    game.setProcessingTurn(true);

    print('Player turn ended, mob turn starting...');

    // Mob attacks after a delay
    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted) {
        _performMobAttack();
      }
    });
  }

  void _performMobAttack() {
    if (!mounted) return;

    // Calculate mob damage based on enemy type and level
    int mobDamage = _calculateMobDamage();

    setState(() {
      // First check if excess health can absorb damage
      if (excessHealth > 0) {
        int excessUsed = mobDamage.clamp(0, excessHealth);
        excessHealth -= excessUsed;
        mobDamage -= excessUsed;

        print(
          'Excess health absorbed $excessUsed damage. Remaining excess: $excessHealth',
        );
      }

      // Apply remaining damage to player health
      if (mobDamage > 0) {
        currentPlayerHealth = (currentPlayerHealth - mobDamage).clamp(
          0,
          maxPlayerHealth,
        );
        print(
          'Mob dealt $mobDamage damage! Player health: $currentPlayerHealth/$maxPlayerHealth',
        );
      }

      // Check if player is defeated
      if (currentPlayerHealth <= 0) {
        _onPlayerDefeated();
        return;
      }

      // Start new player turn
      isPlayerTurn = true;
      isProcessingTurn = false;
    });

    // Sync with game
    game.setPlayerTurn(true);
    game.setProcessingTurn(false);

    print('Mob turn ended, player turn starting...');
  }

  int _calculateMobDamage() {
    // Base damage varies by enemy type
    int baseDamage = 15; // Default damage

    if (widget.chapter == 1) {
      if (widget.level == 1 || widget.level == 2) {
        // Goblin - weak damage
        baseDamage = 10;
      } else if (widget.level == 3 || widget.level == 4) {
        // Ghost - medium damage
        baseDamage = 15;
      } else if (widget.level == 5) {
        // Dragon - high damage
        baseDamage = 25;
      }
    }

    // Add some randomness (±25%)
    int variance = (baseDamage * 0.25).round();
    int finalDamage =
        baseDamage + (Random().nextInt(variance * 2 + 1) - variance);

    return finalDamage.clamp(1, baseDamage * 2); // Ensure at least 1 damage
  }

  void _onPlayerDefeated() {
    print('Player defeated!');
    AudioManager().playButtonSound();

    // Show game over dialog
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
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red[800]!, width: 4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'DEFEAT!',
                  style: TextStyle(
                    fontFamily: 'Bungee',
                    fontSize: MediaQuery.of(context).size.width * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    AudioManager().playButtonSound();
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Return to previous screen
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.red[800]!, width: 3),
                    ),
                    child: Text(
                      'RETRY',
                      style: TextStyle(
                        fontFamily: 'Bungee',
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

  void _onPowerBarClicked() {
    // Only allow power attack during player turn and if bar is full
    if (!isPlayerTurn || isProcessingTurn) {
      print('Cannot use power during enemy turn!');
      return;
    }

    if (currentPowerPoints >= maxPowerPoints) {
      AudioManager().playButtonSound();

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
          return; // End turn immediately if enemy is defeated
        }
      });

      // End player turn after power attack
      _checkEndPlayerTurn();
    } else {
      print(
        'Power bar not full yet. Need ${maxPowerPoints - currentPowerPoints} more power.',
      );
    }
  }

  void _onEnemyDefeated() {
    print('Enemy defeated!');
    // TODO: Add victory logic, move to next level, etc.
    AudioManager().playButtonSound();

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
                    fontFamily: 'Bungee',
                    fontSize: MediaQuery.of(context).size.width * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    AudioManager().playButtonSound();
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
                        fontFamily: 'Bungee',
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
    AudioManager().playButtonSound();
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
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              color: Colors.brown[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.brown[800]!, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'GAME PAUSED',
                  style: TextStyle(
                    fontFamily: 'Bungee',
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'What would you like to do?',
                  style: TextStyle(
                    fontFamily: 'Bungee',
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    color: Colors.brown[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Continue button using continue.png
                    GestureDetector(
                      onTap: () {
                        AudioManager().playButtonSound();
                        setState(() {
                          _isPaused = false;
                        });
                        game.paused = false;
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/ui/continue.png',
                          height: 60,
                          width: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 60,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.green[600],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.green[800]!,
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'CONTINUE',
                                  style: TextStyle(
                                    fontFamily: 'Bungee',
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Back button using backbutton.png
                    GestureDetector(
                      onTap: () {
                        AudioManager().playButtonSound();
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Exit to previous screen
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/ui/backbutton.png',
                          height: 60,
                          width: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.red[600],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.red[800]!,
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            );
                          },
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
                image: AssetImage('assets/images/backgrounds/Gameplaybg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Fallback background if image fails to load
          Container(
            color: Colors.brown[200],
            child: Image.asset(
              'assets/images/backgrounds/Gameplaybg.png',
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
                        fontFamily: 'Bungee',
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
                            fontFamily: 'Bungee',
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
                            'assets/images/ui/PauseButton.png',
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
                                  'assets/images/mobs/Goblin.png',
                                  Colors.green,
                                  'GOBLIN',
                                  screenWidth,
                                  screenHeight,
                                ),
                              if (widget.chapter == 1 &&
                                  (widget.level == 3 || widget.level == 4))
                                _buildEnemyWidget(
                                  'assets/images/mobs/Ghost.png',
                                  Colors.grey,
                                  'GHOST',
                                  screenWidth,
                                  screenHeight,
                                ),
                              if (widget.chapter == 1 && widget.level == 5)
                                _buildEnemyWidget(
                                  'assets/images/mobs/Dragon.png',
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
                        Expanded(
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

          // Weapon image (positioned above all)
          Positioned(
            right: _equippedWeapon == 'Hand' || _equippedWeapon == 'Dagger'
                ? screenWidth *
                      0.01 // Closer to edge for smaller weapons
                : screenWidth * 0.02, // Standard position for Sword
            top: screenHeight * 0.25,
            child: Image.asset(
              _weaponAssets[_equippedWeapon] ??
                  'assets/images/items/SwordHand.png',
              width: _equippedWeapon == 'Hand' || _equippedWeapon == 'Dagger'
                  ? screenWidth *
                        0.25 // Larger size for smaller weapons
                  : screenWidth * 0.2, // Standard size for Sword
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width:
                      _equippedWeapon == 'Hand' || _equippedWeapon == 'Dagger'
                      ? screenWidth *
                            0.25 // Match larger size for smaller weapons
                      : screenWidth * 0.2, // Standard size for Sword
                  height: screenHeight * 0.25,
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
                    fontFamily: 'Bungee',
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
                      fontFamily: 'Bungee',
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
    // Make the grid as large as possible horizontally, up to 90% of screen width, and only limit height if it would overflow
    return LayoutBuilder(
      builder: (context, constraints) {
        double gridWidth = screenWidth * 0.9;
        double gridHeight = gridWidth;
        // If grid would overflow vertically, shrink to fit
        double maxAllowedHeight = constraints.maxHeight;
        if (gridHeight > maxAllowedHeight) {
          gridHeight = maxAllowedHeight;
          gridWidth = gridHeight;
        }
        return Center(
          child: SizedBox(
            width: gridWidth,
            height: gridHeight,
            child: GameWidget<Match3Game>.controlled(gameFactory: () => game),
          ),
        );
      },
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
                Row(
                  children: [
                    Text(
                      'HEALTH',
                      style: TextStyle(
                        fontFamily: 'Bungee',
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
                    if (excessHealth > 0) ...[
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        '(+$excessHealth)',
                        style: TextStyle(
                          fontFamily: 'Bungee',
                          color: Colors.lightGreen,
                          fontSize: screenWidth * 0.025,
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
                    ],
                  ],
                ),
                SizedBox(height: screenHeight * 0.005),
                Container(
                  height: screenHeight * 0.02,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Stack(
                    children: [
                      // Health bar fill
                      Container(
                        width:
                            (screenWidth * 0.75 * 0.5 - screenWidth * 0.03) *
                            (currentPlayerHealth / maxPlayerHealth),
                        decoration: BoxDecoration(
                          color: currentPlayerHealth >= maxPlayerHealth * 0.7
                              ? Colors.green[600] // Healthy
                              : currentPlayerHealth >= maxPlayerHealth * 0.3
                              ? Colors.orange[600] // Warning
                              : Colors.red[600], // Critical
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // Health text overlay - show current turn status for player
                      Center(
                        child: Text(
                          isPlayerTurn && !isProcessingTurn
                              ? '$currentPlayerHealth/$maxPlayerHealth'
                              : isProcessingTurn
                              ? 'Enemy Turn...'
                              : '$currentPlayerHealth/$maxPlayerHealth',
                          style: TextStyle(
                            fontFamily: 'Bungee',
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
                    fontFamily: 'Bungee',
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
                              fontFamily: 'Bungee',
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

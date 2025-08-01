import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../managers/audio_manager.dart';
import '../managers/upgrade_manager.dart';
import '../core/flame_match3_game.dart';

class TowerGameplayScreen extends StatefulWidget {
  final int initialFloor;

  const TowerGameplayScreen({super.key, this.initialFloor = 1});

  @override
  _TowerGameplayScreenState createState() => _TowerGameplayScreenState();
}

class _TowerGameplayScreenState extends State<TowerGameplayScreen> {
  bool _isPaused = false;
  late Match3Game game;
  late int currentFloor;
  final Random _random = Random();

  // Enemy configuration
  int maxEnemyHealth = 100;
  int currentEnemyHealth = 100;
  late String enemyAsset;
  late String enemyLabel;
  late Color enemyColor;
  bool isDragon = false;
  int damageThresholdIncrease = 0;

  // Persistent player stats
  static int maxPlayerHealth = 100;
  static int currentPlayerHealth = 100;
  static int excessHealth = 0;
  static int maxPowerPoints = 50;
  static int currentPowerPoints = 0;
  static int shieldPoints = 0;
  static const int shieldBlockThreshold = 10;

  // Damage and healing values
  static const int swordDamage = 10;
  static const int starPowerGain = 5;
  static const int powerAttackDamage = 50;

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

  // Weapon passive tracking
  int _daggerHeartMatches = 0; // Track heart matches for dagger passive

  // Enemy types for randomization
  final List<Map<String, dynamic>> enemyTypes = [
    {
      'asset': 'assets/images/mobs/Goblin.png',
      'label': 'GOBLIN',
      'color': Colors.green,
      'baseHealth': 100,
      'baseDamage': 10,
      'isDragon': false,
    },
    {
      'asset': 'assets/images/mobs/Ghost.png',
      'label': 'GHOST',
      'color': Colors.grey,
      'baseHealth': 150,
      'baseDamage': 15,
      'isDragon': false,
    },
    {
      'asset': 'assets/images/mobs/Dragon.png',
      'label': 'DRAGON',
      'color': Colors.red,
      'baseHealth': 300,
      'baseDamage': 25,
      'isDragon': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    currentFloor = widget.initialFloor;
    _loadEquippedWeapon();
    _loadUpgrades();
    _initializeEnemy();
    _initializeGame();

    // Reset weapon passive counters for new battle
    _daggerHeartMatches = 0;
  }

  Future<void> _loadUpgrades() async {
    await UpgradeManager.instance.loadUpgrades();
  }

  Future<void> _loadEquippedWeapon() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _equippedWeapon = prefs.getString('equipped_weapon') ?? 'Sword';
    });
  }

  void _initializeGame() {
    game = Match3Game();
    game.onMatchCallback = _handleMatch;
    game.onAllMatchesCompleteCallback = _onAllMatchesComplete;
    game.onMobAttackCallback = _handleMobAttack;
    game.setPlayerTurn(isPlayerTurn);
    game.setProcessingTurn(isProcessingTurn);
    game.playerHealth = currentPlayerHealth;
    game.playerPower = currentPowerPoints;
    game.canUsePower = currentPowerPoints >= maxPowerPoints;
    // Sync enemy health
    game.enemyHealth = currentEnemyHealth;
    game.maxEnemyHealth = maxEnemyHealth;
    print(
      'Game initialized: Floor=$currentFloor, PlayerTurn=$isPlayerTurn, Processing=$isProcessingTurn, Enemy HP=$currentEnemyHealth/$maxEnemyHealth',
    );
  }

  void _initializeEnemy() {
    final enemy = enemyTypes[_random.nextInt(enemyTypes.length)];
    enemyAsset = enemy['asset'];
    enemyLabel = enemy['label'];
    enemyColor = enemy['color'];
    maxEnemyHealth = enemy['baseHealth'];
    currentEnemyHealth = maxEnemyHealth;
    isDragon = enemy['isDragon'];
    damageThresholdIncrease = currentFloor - 1;
    print(
      'Floor $currentFloor: Facing $enemyLabel (Health: $maxEnemyHealth, Damage Increase: $damageThresholdIncrease)',
    );
  }

  void _handleMatch(int tileType, int matchCount, int score) {
    if (!mounted) return;

    setState(() {
      switch (tileType) {
        case 0: // Sword
          int effectiveSwordDamage =
              UpgradeManager.instance.effectiveSwordDamage;
          int damage = effectiveSwordDamage * (matchCount ~/ 3);
          if (matchCount > 3) damage += (matchCount - 3) * 2;
          currentEnemyHealth = (currentEnemyHealth - damage).clamp(
            0,
            maxEnemyHealth,
          );

          // Play enemy hurt sound when damaged
          if (damage > 0) {
            AudioManager().playEnemyHurt();
          }

          game.enemyHealth = currentEnemyHealth; // Sync with game
          print(
            'Sword match: $damage damage (upgraded from $swordDamage to $effectiveSwordDamage), Enemy HP: $currentEnemyHealth/$maxEnemyHealth',
          );
          if (currentEnemyHealth <= 0) {
            Future.delayed(Duration(milliseconds: 500), () {
              if (mounted) _onEnemyDefeated();
            });
          }
          break;
        case 1: // Shield
          int effectiveShieldPoints =
              UpgradeManager.instance.effectiveShieldPoints;
          int gainedShieldPoints =
              effectiveShieldPoints * (matchCount ~/ 3) +
              effectiveShieldPoints; // Each shield tile contributes upgraded amount
          shieldPoints += gainedShieldPoints;
          print(
            'Shield match! Gained $gainedShieldPoints shield points (upgraded from $matchCount to ${matchCount}x$effectiveShieldPoints). Shield: $shieldPoints/$shieldBlockThreshold',
          );
          break;
        case 2: // Heart
          int effectiveHeartHeal = UpgradeManager.instance.effectiveHeartHeal;
          int healing = effectiveHeartHeal * (matchCount ~/ 3);
          if (matchCount > 3) healing += (matchCount - 3) * 2;

          // Dagger passive: Track heart matches and provide bonus healing every 5 matches
          int bonusHealing = 0;
          if (_equippedWeapon == 'Dagger') {
            _daggerHeartMatches++;
            if (_daggerHeartMatches >= 5) {
              bonusHealing = 10;
              _daggerHeartMatches = 0; // Reset counter
              print('Dagger passive triggered! Bonus +$bonusHealing HP');
            }
          }

          int totalHealing = healing + bonusHealing;
          int missingHealth = maxPlayerHealth - currentPlayerHealth;
          int actualHealing = totalHealing.clamp(0, missingHealth);
          int excess = totalHealing - actualHealing;
          currentPlayerHealth += actualHealing;
          excessHealth += excess;
          game.playerHealth = currentPlayerHealth; // Sync with game
          print(
            'Heart match: $actualHealing HP (base: $healing${bonusHealing > 0 ? ' + dagger bonus: $bonusHealing' : ''}) (+$excess excess), Player HP: $currentPlayerHealth/$maxPlayerHealth${_equippedWeapon == 'Dagger' ? ' [Dagger: $_daggerHeartMatches/5]' : ''}',
          );
          break;
        case 3: // Star
          int effectiveStarPowerGain =
              UpgradeManager.instance.effectiveStarPowerGain;
          int powerGain = effectiveStarPowerGain * (matchCount ~/ 3);
          if (matchCount > 3) powerGain += (matchCount - 3) * 2;
          currentPowerPoints = (currentPowerPoints + powerGain).clamp(
            0,
            maxPowerPoints,
          );
          game.playerPower = currentPowerPoints; // Sync with game
          game.canUsePower = currentPowerPoints >= maxPowerPoints;
          print(
            'Star match: $powerGain power (upgraded from $starPowerGain to $effectiveStarPowerGain), Power: $currentPowerPoints/$maxPowerPoints',
          );
          break;
      }
    });
  }

  void _handleMobAttack(int damage) {
    if (!mounted) return;
    setState(() {
      // Use the scaling damage from Match3Game directly, no additional floor damage
      int finalDamage = damage;

      // Shield blocking system
      if (shieldPoints >= shieldBlockThreshold) {
        shieldPoints = 0; // Reset shield points after blocking
        finalDamage = 0; // Block all damage
        print('Shield blocked all damage! Shield points reset.');
      }

      if (excessHealth > 0) {
        int excessUsed = finalDamage.clamp(0, excessHealth);
        excessHealth -= excessUsed;
        finalDamage -= excessUsed;
        print('Excess health absorbed $excessUsed damage');
      }
      if (finalDamage > 0) {
        // Play player damaged sound
        AudioManager().playPlayerDamaged();

        currentPlayerHealth = (currentPlayerHealth - finalDamage).clamp(
          0,
          maxPlayerHealth,
        );
        game.playerHealth = currentPlayerHealth; // Sync with game
        print(
          'Mob dealt $finalDamage damage, Player HP: $currentPlayerHealth/$maxPlayerHealth',
        );
      }
      if (currentPlayerHealth <= 0) {
        _onPlayerDefeated();
      }
      isProcessingTurn = false;
      isPlayerTurn = true;
      game.setPlayerTurn(true);
      game.setProcessingTurn(false);
      print(
        'Mob attack complete: PlayerTurn=$isPlayerTurn, Processing=$isProcessingTurn',
      );
    });
  }

  void _onAllMatchesComplete() {
    if (!mounted) return;
    if (currentEnemyHealth > 0 && isPlayerTurn && !isProcessingTurn) {
      setState(() {
        isPlayerTurn = false;
        isProcessingTurn = true;
        game.setPlayerTurn(false);
        game.setProcessingTurn(true);
        print(
          'Matches complete, starting enemy turn: PlayerTurn=$isPlayerTurn, Processing=$isProcessingTurn',
        );
      });
      Future.delayed(Duration(milliseconds: 800), () {
        if (mounted && !isPlayerTurn && isProcessingTurn) {
          game.enemyTurn();
        }
      });
    } else {
      setState(() {
        isProcessingTurn = false;
        isPlayerTurn = true;
        game.setPlayerTurn(true);
        game.setProcessingTurn(false);
        print(
          'Matches complete, no enemy turn needed: PlayerTurn=$isPlayerTurn, Processing=$isProcessingTurn',
        );
      });
    }
  }

  void _onPlayerDefeated() {
    AudioManager().playButtonSound();
    setState(() {
      isProcessingTurn = true;
      game.setProcessingTurn(true);
      print('Player defeated: Processing=$isProcessingTurn');
    });
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
                    fontSize: MediaQuery.of(context).size.width * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    AudioManager().playButtonSound();
                    setState(() {
                      // Reset player stats
                      currentPlayerHealth = maxPlayerHealth;
                      excessHealth = 0;
                      shieldPoints = 0;
                      currentPowerPoints = 0;
                      currentFloor = 1;
                      _initializeEnemy();
                      _initializeGame();
                      isPlayerTurn = true;
                      isProcessingTurn = false;
                      print(
                        'Game reset: PlayerTurn=$isPlayerTurn, Processing=$isProcessingTurn',
                      );
                    });
                    Navigator.pop(context);
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

  void _onEnemyDefeated() {
    AudioManager().playButtonSound();
    setState(() {
      isProcessingTurn = true;
      game.setProcessingTurn(true);
      print('Enemy defeated: Processing=$isProcessingTurn');
    });
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
                  'FLOOR $currentFloor CLEARED!',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    AudioManager().playButtonSound();
                    setState(() {
                      currentFloor++;
                      _initializeEnemy();
                      // Reset game state instead of creating new instance
                      game.startNewBattle(); // Reset enemy damage scaling
                      game.setPlayerTurn(true);
                      game.setProcessingTurn(false);
                      game.playerHealth = currentPlayerHealth;
                      game.playerPower = currentPowerPoints;
                      game.canUsePower = currentPowerPoints >= maxPowerPoints;
                      // Sync enemy health
                      game.enemyHealth = currentEnemyHealth;
                      game.maxEnemyHealth = maxEnemyHealth;
                      // Clear any selected tile
                      if (game.selectedTile != null) {
                        game.selectedTile!.setSelected(false);
                        game.selectedTile = null;
                      }
                      // Reset weapon passive counters for new floor
                      _daggerHeartMatches = 0;
                      isPlayerTurn = true;
                      isProcessingTurn = false;
                      print(
                        'Next floor: Floor=$currentFloor, PlayerTurn=$isPlayerTurn, Processing=$isProcessingTurn',
                      );
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.green[600],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.green[800]!, width: 3),
                    ),
                    child: Text(
                      'NEXT FLOOR',
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
                    GestureDetector(
                      onTap: () {
                        AudioManager().playButtonSound();
                        setState(() {
                          _isPaused = false;
                          isProcessingTurn = false;
                          isPlayerTurn = true;
                          game.setPlayerTurn(true);
                          game.setProcessingTurn(false);
                          print(
                            'Resumed: PlayerTurn=$isPlayerTurn, Processing=$isProcessingTurn',
                          );
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
                    GestureDetector(
                      onTap: () {
                        AudioManager().playButtonSound();
                        setState(() {
                          // Reset player stats on exit
                          currentPlayerHealth = maxPlayerHealth;
                          excessHealth = 0;
                          shieldPoints = 0;
                          currentPowerPoints = 0;
                          currentFloor = 1;
                          isProcessingTurn = false;
                          isPlayerTurn = true;
                          print(
                            'Exit to main menu: PlayerTurn=$isPlayerTurn, Processing=$isProcessingTurn',
                          );
                        });
                        Navigator.pop(context);
                        Navigator.pop(context);
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

  void _onPowerBarClicked() {
    if (!isPlayerTurn || isProcessingTurn) {
      print(
        'Cannot use power: PlayerTurn=$isPlayerTurn, Processing=$isProcessingTurn',
      );
      return;
    }
    if (currentPowerPoints >= maxPowerPoints) {
      AudioManager().playButtonSound();
      setState(() {
        // Calculate power attack damage with Hand weapon passive
        int actualPowerDamage = powerAttackDamage;
        if (_equippedWeapon == 'Hand') {
          actualPowerDamage = powerAttackDamage * 2; // Double damage for Hand
        }

        currentEnemyHealth = (currentEnemyHealth - actualPowerDamage).clamp(
          0,
          maxEnemyHealth,
        );

        // Play enemy hurt sound for power attack
        AudioManager().playEnemyHurt();
        game.enemyHealth = currentEnemyHealth; // Sync with game
        currentPowerPoints = 0;
        game.playerPower = 0;
        game.canUsePower = false;
        isPlayerTurn = false;
        isProcessingTurn = true;
        game.setPlayerTurn(false);
        game.setProcessingTurn(true);
        print(
          'Power attack: $actualPowerDamage damage${_equippedWeapon == 'Hand' ? ' (Hand passive: double damage!)' : ''}, Enemy HP: $currentEnemyHealth/$maxEnemyHealth',
        );
      });
      if (currentEnemyHealth <= 0) {
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) _onEnemyDefeated();
        });
      } else {
        Future.delayed(Duration(milliseconds: 1000), () {
          if (mounted) {
            game.enemyTurn();
          }
        });
      }
    }
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
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/backgrounds/Gameplaybg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
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
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.01,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                          'Floor $currentFloor',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: screenHeight * 0.35,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildEnemyWidget(
                                enemyAsset,
                                enemyColor,
                                enemyLabel,
                                screenWidth,
                                screenHeight,
                                isDragon: isDragon,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
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

  Widget _buildEnemyWidget(
    String assetPath,
    Color baseColor,
    String label,
    double screenWidth,
    double screenHeight, {
    bool isDragon = false,
  }) {
    Color lightShade = baseColor == Colors.green
        ? Color.fromRGBO(200, 230, 201, 1.0)
        : baseColor == Colors.grey
        ? Color.fromRGBO(189, 189, 189, 1.0)
        : Color.fromRGBO(255, 205, 210, 1.0);
    Color darkShade = baseColor == Colors.green
        ? Color.fromRGBO(76, 175, 80, 1.0)
        : baseColor == Colors.grey
        ? Color.fromRGBO(117, 117, 117, 1.0)
        : Color.fromRGBO(229, 115, 115, 1.0);

    return Column(
      children: [
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
        SizedBox(height: screenHeight * 0.005),
        Image.asset(
          assetPath,
          width: isDragon ? screenWidth * 0.6 : screenWidth * 0.3,
          height: isDragon ? screenWidth * 0.4 : screenWidth * 0.3,
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
                    size: isDragon ? screenWidth * 0.15 : screenWidth * 0.1,
                    color: darkShade,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: darkShade,
                      fontSize: isDragon
                          ? screenWidth * 0.05
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
                    if (shieldPoints > 0) ...[
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        '🛡️$shieldPoints',
                        style: TextStyle(
                          color: Colors.cyan,
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
                      Container(
                        width:
                            (screenWidth * 0.75 * 0.5 - screenWidth * 0.03) *
                            (currentPlayerHealth / maxPlayerHealth),
                        decoration: BoxDecoration(
                          color: currentPlayerHealth >= maxPlayerHealth * 0.7
                              ? Colors.green[600]
                              : currentPlayerHealth >= maxPlayerHealth * 0.3
                              ? Colors.orange[600]
                              : Colors.red[600],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Center(
                        child: Text(
                          isPlayerTurn && !isProcessingTurn
                              ? '$currentPlayerHealth/$maxPlayerHealth'
                              : isProcessingTurn
                              ? 'Enemy Turn...'
                              : '$currentPlayerHealth/$maxPlayerHealth',
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
                        Container(
                          width:
                              (screenWidth * 0.75 * 0.5 - screenWidth * 0.03) *
                              (currentPowerPoints / maxPowerPoints),
                          decoration: BoxDecoration(
                            color: currentPowerPoints >= maxPowerPoints
                                ? Colors.orange[600]
                                : Colors.yellow[600],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
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

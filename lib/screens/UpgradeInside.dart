import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../managers/language_manager.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  _UpgradeScreenState createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  int _coins = 9999;

  // Track upgrade levels (initially set to 1)
  Map<String, int> upgradeLevels = {
    'sword': 1,
    'heart': 1,
    'star': 1,
    'shield': 1,
  };

  // Track progress for each upgrade (0-4 steps)
  Map<String, int> upgradeProgress = {
    'sword': 0,
    'heart': 0,
    'star': 0,
    'shield': 0,
  };

  // Upgrade prices
  Map<String, int> upgradePrices = {
    'sword': 100,
    'heart': 120,
    'star': 150,
    'shield': 180,
  };

  // Maximum level for upgrades
  static const int maxLevel = 4;

  @override
  void initState() {
    super.initState();
    LanguageManager.initializeLanguage();
  }

  void _showPurchaseDialog(String upgradeType) {
    final price = upgradePrices[upgradeType]!;

    // Check if already at max level
    if (upgradeProgress[upgradeType]! >= maxLevel && upgradeLevels[upgradeType]! >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LanguageManager.getText('maxLevel')),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LanguageManager.getText('confirmPurchase'),
                  style: const TextStyle(
                    fontFamily: 'Bungee',
                    fontSize: 24,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${LanguageManager.getText('purchaseFor')} $price ${LanguageManager.getText('coins')}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => _confirmPurchase(upgradeType),
                      child: Image.asset(
                        'assets/images/ui/confirm.png',
                        height: 60,
                        width: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 60,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                LanguageManager.getText('confirm'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Image.asset(
                        'assets/images/ui/refuse.png',
                        height: 60,
                        width: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 60,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                LanguageManager.getText('refuse'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
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

  void _confirmPurchase(String upgradeType) {
    final price = upgradePrices[upgradeType]!;

    Navigator.of(context).pop(); // Close dialog

    if (_coins >= price) {
      setState(() {
        _coins -= price;
        if (upgradeProgress[upgradeType]! < maxLevel && upgradeLevels[upgradeType]! < 10) {
          upgradeProgress[upgradeType] = (upgradeProgress[upgradeType]! + 1);
          if (upgradeProgress[upgradeType] == maxLevel) {
            upgradeLevels[upgradeType] = (upgradeLevels[upgradeType]! + 1);
            upgradeProgress[upgradeType] = 0; // Reset progress after reaching max level
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LanguageManager.getText('purchaseSuccess')),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LanguageManager.getText('notEnoughCoins')),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _purchaseUpgrade(String upgradeType) {
    _showPurchaseDialog(upgradeType);
  }

  Widget _buildProgressBar(int progress, double screenWidth) {
    double dotSize = screenWidth * 0.06;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.008),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index < progress
                  ? Colors.greenAccent.withOpacity(0.9)
                  : Colors.grey[700]!.withOpacity(0.5),
              border: Border.all(
                color: index < progress ? Colors.green : Colors.grey[400]!,
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: index < progress
                      ? Colors.green.withOpacity(0.4)
                      : Colors.black.withOpacity(0.2),
                  blurRadius: 3,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                index < progress ? Icons.circle : Icons.circle_outlined,
                size: dotSize * 0.6,
                color: index < progress ? Colors.white : Colors.grey[300],
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrounds/backgroundshop.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Text(
                      'Background image not found',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),

          // Top Bar
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.03,
            right: screenWidth * 0.03,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Custom Image Label with "UPGRADES" - Responsive
                GestureDetector(
                  onTap: () {
                    // Add your upgrades button functionality here if needed
                  },
                  child: Stack(
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
                            decoration: BoxDecoration(
                              color: Colors.brown,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        },
                      ),
                      Text(
                        LanguageManager.getText('upgrades'),
                        style: TextStyle(
                          fontFamily: 'Bungee',
                          fontSize: screenWidth * 0.04,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              blurRadius: 2,
                              color: Colors.black,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Coin Count
                Row(
                  children: [
                    Text(
                      '$_coins',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: screenWidth * 0.06,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Center Upgrade List
          Positioned(
            top: screenHeight * 0.15,
            left: 0,
            right: 0,
            bottom: screenHeight * 0.12,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildUpgradeRow(
                      context,
                      'sword',
                      'LVL ${upgradeLevels['sword']}',
                      Colors.red,
                      screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    _buildUpgradeRow(
                      context,
                      'heart',
                      'LVL ${upgradeLevels['heart']}',
                      Colors.green,
                      screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    _buildUpgradeRow(
                      context,
                      'star',
                      'LVL ${upgradeLevels['star']}',
                      Colors.yellow,
                      screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    _buildUpgradeRow(
                      context,
                      'shield',
                      'LVL ${upgradeLevels['shield']}',
                      Colors.blue,
                      screenWidth,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom back button
          Positioned(
            bottom: screenHeight * 0.02,
            right: screenWidth * 0.04,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset(
                'assets/images/ui/backbutton.png',
                height: screenWidth * 0.18,
                width: screenWidth * 0.18,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: screenWidth * 0.18,
                    width: screenWidth * 0.18,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: screenWidth * 0.09,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeRow(
      BuildContext context,
      String upgradeType,
      String levelText,
      Color color,
      double screenWidth,
      ) {
    return Container(
      width: double.infinity,
      height: screenWidth * 0.3,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Upgrade Icon with Level Text Below
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Container
                Container(
                  width: screenWidth * 0.18,
                  height: screenWidth * 0.18,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(screenWidth * 0.09),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.025),
                    child: Image.asset(
                      upgradeType == 'sword'
                          ? 'assets/images/items/sword.png'
                          : upgradeType == 'heart'
                          ? 'assets/images/items/heart.png'
                          : upgradeType == 'star'
                          ? 'assets/images/items/star.png'
                          : 'assets/images/items/shield.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.inventory,
                          color: Colors.white,
                          size: screenWidth * 0.08,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: screenWidth * 0.015),
                // Level Text Below Icon
                Text(
                  levelText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Bungee',
                  ),
                ),
              ],
            ),
          ),

          // Progress Bar
          Expanded(
            flex: 3,
            child: Center(
              child: _buildProgressBar(
                upgradeProgress[upgradeType]!,
                screenWidth,
              ),
            ),
          ),

          // Purchase Button with PNG and Price
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _purchaseUpgrade(upgradeType),
                  child: Container(
                    width: screenWidth * 0.13,
                    height: screenWidth * 0.13,
                    decoration: const BoxDecoration(
                      color: Colors.brown,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/ui/plusbutton.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.add,
                          color: Colors.white,
                          size: screenWidth * 0.07,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                // Price and Coin Icon
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${upgradePrices[upgradeType]}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.04,
                          fontFamily: 'Bungee',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: screenWidth * 0.05,
                      ),
                    ],
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
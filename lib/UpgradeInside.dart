import 'package:flutter/material.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  _UpgradeScreenState createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
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

  // Maximum level for upgrades
  static const int maxLevel = 4;

  void _purchaseUpgrade(String upgradeType) {
    setState(() {
      if (upgradeProgress[upgradeType]! < maxLevel &&
          upgradeLevels[upgradeType]! < 10) {
        upgradeProgress[upgradeType] = (upgradeProgress[upgradeType]! + 1);
        if (upgradeProgress[upgradeType] == maxLevel) {
          upgradeLevels[upgradeType] = (upgradeLevels[upgradeType]! + 1);
          upgradeProgress[upgradeType] =
              0; // Reset progress after reaching max level
        }
      }
    });
  }

  Widget _buildProgressBar(int progress, double screenWidth) {
    double dotSize = screenWidth * 0.04; // Responsive dot size
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.005),
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
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: index < progress
                      ? Colors.green.withOpacity(0.4)
                      : Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  spreadRadius: 0.5,
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
              'assets/backgroundshop.png',
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
                        'UPGRADES',
                        style: TextStyle(
                          fontFamily: 'Bungee',
                          fontSize: screenWidth * 0.045,
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
                // Coin Count
                Row(
                  children: [
                    Text(
                      '9999',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black,
                            offset: const Offset(1, 1),
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
                    SizedBox(height: screenHeight * 0.02),
                    _buildUpgradeRow(
                      context,
                      'heart',
                      'LVL ${upgradeLevels['heart']}',
                      Colors.green,
                      screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _buildUpgradeRow(
                      context,
                      'star',
                      'LVL ${upgradeLevels['star']}',
                      Colors.yellow,
                      screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.02),
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
                'assets/backbutton.png',
                height: screenWidth * 0.12,
                width: screenWidth * 0.12,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: screenWidth * 0.12,
                    width: screenWidth * 0.12,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: screenWidth * 0.06,
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
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Upgrade Icon Space with PNG
          Container(
            width: screenWidth * 0.15,
            height: screenWidth * 0.15,
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(screenWidth * 0.075),
            ),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Image.asset(
                upgradeType == 'sword'
                    ? 'assets/sword.png'
                    : upgradeType == 'heart'
                    ? 'assets/heart.png'
                    : upgradeType == 'star'
                    ? 'assets/star.png'
                    : 'assets/shield.png',
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

          // Level Text
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                levelText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Bungee',
                ),
              ),
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
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.1,
                    decoration: const BoxDecoration(
                      color: Colors.brown,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/plusbutton.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.add,
                          color: Colors.white,
                          size: screenWidth * 0.05,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.015),
                // Price and Coin Icon
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '100',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.035,
                          fontFamily: 'Bungee',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.008),
                      Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: screenWidth * 0.04,
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

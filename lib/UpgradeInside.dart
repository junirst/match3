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
      if (upgradeProgress[upgradeType]! < maxLevel && upgradeLevels[upgradeType]! < 10) {
        upgradeProgress[upgradeType] = (upgradeProgress[upgradeType]! + 1);
        if (upgradeProgress[upgradeType] == maxLevel) {
          upgradeLevels[upgradeType] = (upgradeLevels[upgradeType]! + 1);
          upgradeProgress[upgradeType] = 0; // Reset progress after reaching max level
        }
      }
    });
  }

  Widget _buildProgressBar(int progress) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 24, // Increased size for visibility
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index < progress ? Colors.greenAccent.withOpacity(0.9) : Colors.grey[700]!.withOpacity(0.5),
              border: Border.all(
                color: index < progress ? Colors.green : Colors.grey[400]!,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: index < progress ? Colors.green.withOpacity(0.4) : Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                index < progress ? Icons.circle : Icons.circle_outlined,
                size: 16,
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
            top: 20, // Adjusted for larger size
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Custom Image Label with "UPGRADES" - Made bigger
                GestureDetector(
                  onTap: () {
                    // Add your upgrades button functionality here if needed
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/frame.png',
                        width: 200, // Increased from 120
                        height: 100, // Increased from 60
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 160,
                            height: 80,
                            color: Colors.grey,
                          );
                        },
                      ),
                      Text(
                        'UPGRADES',
                        style: TextStyle(
                          fontFamily: 'Bungee',
                          fontSize: 24, // Increased for larger box
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
                    const Text(
                      '9999',
                      style: TextStyle(
                        fontSize: 24,
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
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 28,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Center Upgrade List
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildUpgradeRow(context, 'sword', 'LVL ${upgradeLevels['sword']}', Colors.red),
                  const SizedBox(height: 25),
                  _buildUpgradeRow(context, 'heart', 'LVL ${upgradeLevels['heart']}', Colors.green),
                  const SizedBox(height: 25),
                  _buildUpgradeRow(context, 'star', 'LVL ${upgradeLevels['star']}', Colors.yellow),
                  const SizedBox(height: 25),
                  _buildUpgradeRow(context, 'shield', 'LVL ${upgradeLevels['shield']}', Colors.blue),
                ],
              ),
            ),
          ),

          // Bottom back button
          Positioned(
            bottom: 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset(
                'assets/backbutton.png',
                height: 60,
                width: 60,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 60,
                    width: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 28,
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

  Widget _buildUpgradeRow(BuildContext context, String upgradeType, String levelText, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Upgrade Icon Space with PNG
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Image.asset(
            upgradeType == 'sword' ? 'assets/sword.png' :
            upgradeType == 'heart' ? 'assets/heart.png' :
            upgradeType == 'star' ? 'assets/star.png' :
            'assets/shield.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.inventory,
                color: Colors.white,
                size: 50,
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        // Level Text
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            levelText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Bungee',
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Progress Bar
        _buildProgressBar(upgradeProgress[upgradeType]!),
        const SizedBox(width: 12),
        // Purchase Button with PNG and Price
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _purchaseUpgrade(upgradeType),
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.brown,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/plusbutton.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 30,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Price and Coin Icon
            Row(
              children: const [
                Text(
                  '100',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Bungee',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 3),
                Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
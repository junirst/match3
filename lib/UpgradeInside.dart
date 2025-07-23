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
          child: Icon(
            index < progress ? Icons.check : Icons.circle_outlined,
            size: 24,
            color: index < progress ? Colors.green : Colors.grey,
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
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Custom Image Label
                Image.asset(
                  'assets/upgradebutton.png',
                  height: 60,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 60,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'UPGRADES',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'DistilleryDisplay',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
                // Coin Count
                Row(
                  children: [
                    const Text(
                      '9999',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 3,
                            color: Colors.black,
                            offset: const Offset(1.5, 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 32,
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
                  const SizedBox(height: 30),
                  _buildUpgradeRow(context, 'heart', 'LVL ${upgradeLevels['heart']}', Colors.green),
                  const SizedBox(height: 30),
                  _buildUpgradeRow(context, 'star', 'LVL ${upgradeLevels['star']}', Colors.yellow),
                  const SizedBox(height: 30),
                  _buildUpgradeRow(context, 'shield', 'LVL ${upgradeLevels['shield']}', Colors.blue),
                ],
              ),
            ),
          ),

          // Bottom back button
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset(
                'assets/backbutton.png',
                height: 70,
                width: 70,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 70,
                    width: 70,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 32,
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
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(60),
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
                size: 60,
              );
            },
          ),
        ),
        const SizedBox(width: 15),
        // Level Text
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            levelText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'DistilleryDisplay',
            ),
          ),
        ),
        const SizedBox(width: 15),
        // Progress Bar
        _buildProgressBar(upgradeProgress[upgradeType]!),
        const SizedBox(width: 15),
        // Purchase Button with PNG and Price
        Row(
          children: [
            GestureDetector(
              onTap: () => _purchaseUpgrade(upgradeType),
              child: Container(
                width: 60,
                height: 60,
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
                      size: 36,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Price and Coin Icon
            Row(
              children: [
                const Text(
                  '100',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: 'DistilleryDisplay',
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 24,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
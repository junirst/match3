import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../managers/language_manager.dart';
import '../managers/audio_manager.dart';
import '../managers/upgrade_manager.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  _UpgradeScreenState createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  int _coins = 9999;

  // Track upgrade levels (initially set to 1, max 5 = 4 upgrades)
  Map<String, int> upgradeLevels = {
    'sword': 1,
    'heart': 1,
    'star': 1,
    'shield': 1,
  };

  // Upgrade prices
  Map<String, int> upgradePrices = {
    'sword': 100,
    'heart': 120,
    'star': 150,
    'shield': 180,
  };

  // Maximum level for upgrades (level 5 = +4 bonus)
  static const int maxUpgradeLevel = 5;

  @override
  void initState() {
    super.initState();
    LanguageManager.initializeLanguage();
    _loadUpgradeData();
  }

  Future<void> _loadUpgradeData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Load coins
      _coins = prefs.getInt('coins') ?? 9999;

      // Load upgrade levels (default to 1)
      upgradeLevels['sword'] = prefs.getInt('upgrade_sword') ?? 1;
      upgradeLevels['heart'] = prefs.getInt('upgrade_heart') ?? 1;
      upgradeLevels['star'] = prefs.getInt('upgrade_star') ?? 1;
      upgradeLevels['shield'] = prefs.getInt('upgrade_shield') ?? 1;
    });
  }

  Future<void> _saveUpgradeData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', _coins);
    await prefs.setInt('upgrade_sword', upgradeLevels['sword']!);
    await prefs.setInt('upgrade_heart', upgradeLevels['heart']!);
    await prefs.setInt('upgrade_star', upgradeLevels['star']!);
    await prefs.setInt('upgrade_shield', upgradeLevels['shield']!);
  }

  void _showUpgradeDialog(String upgradeType) {
    final currentLevel = upgradeLevels[upgradeType]!;
    final maxPossibleLevel = maxUpgradeLevel;

    // Check if already at max level
    if (currentLevel >= maxPossibleLevel) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LanguageManager.getText('maxLevel')),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Calculate how many levels can be upgraded
    final maxUpgradeSteps = maxPossibleLevel - currentLevel;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _UpgradeQuantityDialog(
          upgradeType: upgradeType,
          currentLevel: currentLevel,
          maxUpgradeSteps: maxUpgradeSteps,
          basePrice: upgradePrices[upgradeType]!,
          coins: _coins,
          onConfirm: _confirmUpgrade,
        );
      },
    );
  }

  void _confirmUpgrade(String upgradeType, int quantity, int totalCost) {
    AudioManager().playButtonSound();
    Navigator.of(context).pop(); // Close dialog

    if (_coins >= totalCost) {
      setState(() {
        _coins -= totalCost;
        upgradeLevels[upgradeType] = upgradeLevels[upgradeType]! + quantity;
      });

      // Sync with UpgradeManager
      UpgradeManager.instance.updateUpgradeLevel(
        upgradeType,
        upgradeLevels[upgradeType]!,
      );
      _saveUpgradeData(); // Save upgrade data

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${LanguageManager.getText('purchaseSuccess')} - Upgraded $quantity levels!',
          ),
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
    AudioManager().playButtonSound();
    _showUpgradeDialog(upgradeType);
  }

  Widget _buildLevelIndicator(int currentLevel, double screenWidth) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Level $currentLevel',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.bold,
            fontFamily: 'Bungee',
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        if (currentLevel < maxUpgradeLevel)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: screenWidth * 0.005,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green, width: 1),
            ),
            child: Text(
              '+${currentLevel - 1}',
              style: TextStyle(
                color: Colors.green,
                fontSize: screenWidth * 0.025,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: screenWidth * 0.005,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange, width: 1),
            ),
            child: Text(
              'MAX',
              style: TextStyle(
                color: Colors.orange,
                fontSize: screenWidth * 0.025,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
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
                AudioManager().playButtonSound();
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

          // Level Indicator
          Expanded(
            flex: 3,
            child: Center(
              child: _buildLevelIndicator(
                upgradeLevels[upgradeType]!,
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

class _UpgradeQuantityDialog extends StatefulWidget {
  final String upgradeType;
  final int currentLevel;
  final int maxUpgradeSteps;
  final int basePrice;
  final int coins;
  final Function(String, int, int) onConfirm;

  const _UpgradeQuantityDialog({
    required this.upgradeType,
    required this.currentLevel,
    required this.maxUpgradeSteps,
    required this.basePrice,
    required this.coins,
    required this.onConfirm,
  });

  @override
  _UpgradeQuantityDialogState createState() => _UpgradeQuantityDialogState();
}

class _UpgradeQuantityDialogState extends State<_UpgradeQuantityDialog> {
  int _selectedQuantity = 1;

  int _calculateTotalCost(int quantity) {
    int totalCost = 0;
    for (int i = 0; i < quantity; i++) {
      // Each level costs more than the previous (basePrice * level)
      totalCost += widget.basePrice * (widget.currentLevel + i);
    }
    return totalCost;
  }

  @override
  Widget build(BuildContext context) {
    final totalCost = _calculateTotalCost(_selectedQuantity);
    final canAfford = widget.coins >= totalCost;

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
              'Upgrade ${widget.upgradeType.toUpperCase()}',
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
              'Current Level: ${widget.currentLevel}',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'Select upgrade quantity:',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Quantity Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _selectedQuantity > 1
                      ? () => setState(() => _selectedQuantity--)
                      : null,
                  icon: Icon(
                    Icons.remove_circle,
                    color: _selectedQuantity > 1 ? Colors.white : Colors.grey,
                    size: 30,
                  ),
                ),
                Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      '$_selectedQuantity',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _selectedQuantity < widget.maxUpgradeSteps
                      ? () => setState(() => _selectedQuantity++)
                      : null,
                  icon: Icon(
                    Icons.add_circle,
                    color: _selectedQuantity < widget.maxUpgradeSteps
                        ? Colors.white
                        : Colors.grey,
                    size: 30,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Text(
              'New Level: ${widget.currentLevel + _selectedQuantity}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Bonus: +$_selectedQuantity to tile value',
              style: const TextStyle(fontSize: 14, color: Colors.yellow),
            ),
            const SizedBox(height: 20),
            Text(
              'Total Cost: $totalCost coins',
              style: TextStyle(
                fontSize: 18,
                color: canAfford ? Colors.white : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: canAfford
                      ? () => widget.onConfirm(
                          widget.upgradeType,
                          _selectedQuantity,
                          totalCost,
                        )
                      : null,
                  child: Opacity(
                    opacity: canAfford ? 1.0 : 0.5,
                    child: Image.asset(
                      'assets/images/ui/confirm.png',
                      height: 60,
                      width: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 60,
                          width: 100,
                          decoration: BoxDecoration(
                            color: canAfford ? Colors.green : Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'CONFIRM',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
                        child: const Center(
                          child: Text(
                            'CANCEL',
                            style: TextStyle(
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
  }
}

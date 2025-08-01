import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../managers/language_manager.dart';
import '../managers/audio_manager.dart';
import '../managers/game_manager.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  void initState() {
    super.initState();
    LanguageManager.initializeLanguage();
  }

  Widget _buildShopButton(
    BuildContext context,
    String translationKey,
    String route,
    double screenWidth,
    double screenHeight,
  ) {
    return GestureDetector(
      onTap: () {
        AudioManager().playButtonSound();
        Navigator.pushNamed(context, route);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/ui/frame.png',
            width: screenWidth * 0.8,
            height: screenHeight * 0.12,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: screenWidth * 0.8,
                height: screenHeight * 0.12,
                color: Colors.grey,
              );
            },
          ),
          Text(
            LanguageManager.getText(translationKey),
            style: TextStyle(
              fontFamily: 'Bungee',
              fontSize: screenWidth * 0.05,
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
            ),
          ),

          // Shop button (Top-left)
          Positioned(
            top: 20,
            left: 20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/ui/frame.png',
                  width: 160,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 160,
                      height: 80,
                      color: Colors.grey,
                    );
                  },
                ),
                Text(
                  LanguageManager.getText('shop'),
                  style: TextStyle(
                    fontFamily: 'Bungee',
                    fontSize: 24,
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

          // Coins (Top-right)
          Positioned(
            top: 40,
            right: 20,
            child: Consumer<GameManager>(
              builder: (context, gameManager, child) {
                return Row(
                  children: [
                    Text(
                      '${gameManager.currentCoins}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 22,
                    ),
                  ],
                );
              },
            ),
          ),

          // Center buttons
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildShopButton(
                  context,
                  'weapons',
                  '/outfit',
                  screenWidth,
                  screenHeight,
                ),
                const SizedBox(height: 30),
                _buildShopButton(
                  context,
                  'upgrade',
                  '/upgrade',
                  screenWidth,
                  screenHeight,
                ),
              ],
            ),
          ),

          // Back button (Bottom-right)
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                AudioManager().playButtonSound();
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                child: Image.asset(
                  'assets/images/ui/backbutton.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

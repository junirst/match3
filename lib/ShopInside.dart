import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  Widget _buildShopButton(BuildContext context, String text, String route, double screenWidth, double screenHeight) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/frame.png',
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
            text,
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
            child: Image.asset('assets/backgroundshop.png', fit: BoxFit.cover),
          ),

          // Shop button (Top-left) - Updated to use frame.png with "SHOP" text, made bigger
          Positioned(
            top: 20, // Adjusted for larger size
            left: 20,
            child: GestureDetector(
              onTap: () {
                // Add your shop button functionality here if needed
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/frame.png',
                    width: 160, // Increased from 120
                    height: 80, // Increased from 60
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 160,
                        height: 80,
                        color: Colors.grey,
                      );
                    },
                  ),
                  Text(
                    'SHOP',
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
          ),

          // Coins (Top-right)
          Positioned(
            top: 40,
            right: 20,
            child: Row(
              children: const [
                Text(
                  '9999',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.monetization_on, color: Colors.amber, size: 22),
              ],
            ),
          ),

          // Center buttons
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildShopButton(context, 'OUTFIT', '/outfit', screenWidth, screenHeight),
                const SizedBox(height: 30),
                _buildShopButton(context, 'UPGRADE', '/upgrade', screenWidth, screenHeight),
              ],
            ),
          ),

          // Back button (Bottom-right)
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                child: Image.asset(
                  'assets/backbutton.png',
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
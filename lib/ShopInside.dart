import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset('assets/backgroundshop.png', fit: BoxFit.cover),
          ),

          // Shop button (Top-left)
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                // Add your shop button functionality here
              },
              child: Container(
                width: 80,
                height: 40,
                child: Image.asset(
                  'assets/shopbutton.png',
                  fit: BoxFit.contain,
                ),
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
                _buildOutfitButton(context),
                const SizedBox(height: 30),
                _buildWeaponButton(context),
                const SizedBox(height: 20),
                _buildUpgradeButton(context),
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

  Widget _buildOutfitButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/outfit');
      },
      child: Container(
        width: 180,
        height: 80,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.asset('assets/outfitbutton.png', fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildWeaponButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/weapon');
      },
      child: Container(
        width: 180,
        height: 80,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.asset('assets/weaponbutton.png', fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildUpgradeButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/upgrade');
      },
      child: Container(
        width: 180,
        height: 80,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.asset('assets/upgradebutton.png', fit: BoxFit.cover),
        ),
      ),
    );
  }
}

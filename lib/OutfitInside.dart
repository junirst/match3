import 'package:flutter/material.dart';

class OutfitScreen extends StatelessWidget {
  const OutfitScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                // Custom Image Label with "OUTFITS"
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/frame.png',
                      height: 100,
                      width: 200,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 80,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      },
                    ),
                    const Text(
                      'WEAPONS',
                      style: TextStyle(
                        fontFamily: 'Bungee',
                        fontSize: 28,
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
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 30,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Invisible container to prevent overlap with top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120, // Height to cover top bar area
            child: Container(
              color: Colors.transparent,
            ),
          ),

          // Center Grid with Scroll
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 140, bottom: 100), // Increased top padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) => [
                  buildItemRow(context),
                  const SizedBox(height: 40),
                ]).expand((element) => element).toList(),
              ),
            ),
          ),

          // Bottom back button
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                // Add safety check for navigation
                if (Navigator.of(context).canPop()) {
                  Navigator.pop(context);
                } else {
                  // Fallback navigation
                  Navigator.pushReplacementNamed(context, '/shop');
                }
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
                      size: 34,
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

  Widget buildItemRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(2, (index) => buildItemCard(context)),
    );
  }

  Widget buildItemCard(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Image.asset(
              'assets/itemslot.png',
              height: 100,
              width: 100,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.inventory,
                    color: Colors.white,
                    size: 50,
                  ),
                );
              },
            ),
            Positioned(
              bottom: 6,
              right: 6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            // Add purchase logic here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Purchase functionality not implemented yet'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Image.asset(
            'assets/buybutton.png',
            height: 50,
            width: 50,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: 28,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
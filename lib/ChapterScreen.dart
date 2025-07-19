import 'package:flutter/material.dart';
import 'audio_manager.dart';

class Chapterscreen extends StatefulWidget {
  const Chapterscreen({super.key});

  @override
  _ChapterscreenState createState() => _ChapterscreenState();
}

class _ChapterscreenState extends State<Chapterscreen> {
  double _chapter1Scale = 1.0;
  double _chapter2Scale = 1.0;
  double _backScale = 1.0;

  void _onButtonTap(String buttonName) {
    // Play sound effect
    AudioManager().playSfx();

    setState(() {
      switch (buttonName) {
        case 'chapter1':
          _chapter1Scale = 1.1;
          break;
        case 'chapter2':
          _chapter2Scale = 1.1;
          break;
        case 'back':
          _backScale = 1.1;
          break;
      }
    });

    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _chapter1Scale = 1.0;
        _chapter2Scale = 1.0;
        _backScale = 1.0;
      });

      if (buttonName == 'back') {
        Navigator.pop(context);
      } else if (buttonName == 'chapter1') {
        Navigator.pushNamed(context, '/chapter1');
      } else if (buttonName == 'chapter2') {
        // Navigate to Chapter 2 gameplay
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chapter 2 functionality not implemented yet'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
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
          // Background image
          Container(
            color: Colors.grey[800],
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey[800]);
              },
            ),
          ),

          // Story Mode button in top left
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.05,
            child: Image.asset(
              'assets/story_button.png',
              width: screenWidth * 0.25,
              height: screenHeight * 0.08,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: screenWidth * 0.25,
                  height: screenHeight * 0.08,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'STORY MODE',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                );
              },
            ),
          ),

          // Center buttons (Chapter 1 and Chapter 2)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Chapter 1 button
                GestureDetector(
                  onTap: () => _onButtonTap('chapter1'),
                  child: AnimatedScale(
                    scale: _chapter1Scale,
                    duration: Duration(milliseconds: 100),
                    child: Image.asset(
                      'assets/Chapter1.png',
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.1,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: screenWidth * 0.6,
                          height: screenHeight * 0.1,
                          decoration: BoxDecoration(
                            color: Colors.brown,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange, width: 2),
                          ),
                          child: const Center(
                            child: Text(
                              'CHAPTER 1',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.05),

                // Chapter 2 button
                GestureDetector(
                  onTap: () => _onButtonTap('chapter2'),
                  child: AnimatedScale(
                    scale: _chapter2Scale,
                    duration: Duration(milliseconds: 100),
                    child: Image.asset(
                      'assets/Chapter2.png',
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.1,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: screenWidth * 0.6,
                          height: screenHeight * 0.1,
                          decoration: BoxDecoration(
                            color: Colors.brown,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange, width: 2),
                          ),
                          child: const Center(
                            child: Text(
                              'CHAPTER 2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Back button in bottom right
          Positioned(
            bottom: screenHeight * 0.03,
            right: screenWidth * 0.03,
            child: GestureDetector(
              onTap: () => _onButtonTap('back'),
              child: AnimatedScale(
                scale: _backScale,
                duration: Duration(milliseconds: 100),
                child: Image.asset(
                  'assets/backbutton.png',
                  width: screenWidth * 0.12,
                  height: screenHeight * 0.08,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: screenWidth * 0.12,
                      height: screenHeight * 0.08,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

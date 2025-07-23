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

  Widget _buildChapterButton(String text, String buttonType, double scale, VoidCallback onTap, double screenWidth, double screenHeight) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: scale,
        duration: Duration(milliseconds: 100),
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
      ),
    );
  }

  Widget _buildStoryModeHeader(double screenWidth, double screenHeight) {
    return Stack(
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
          'STORY MODE',
          style: TextStyle(
            fontFamily: 'Bungee',
            fontSize: screenWidth * 0.03,
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
    );
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

          // Story Mode header in top left
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.05,
            child: _buildStoryModeHeader(screenWidth, screenHeight),
          ),

          // Center buttons (Chapter 1 and Chapter 2)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Chapter 1 button
                _buildChapterButton(
                  'CHAPTER 1',
                  'chapter1',
                  _chapter1Scale,
                      () => _onButtonTap('chapter1'),
                  screenWidth,
                  screenHeight,
                ),

                SizedBox(height: screenHeight * 0.05),

                // Chapter 2 button
                _buildChapterButton(
                  'CHAPTER 2',
                  'chapter2',
                  _chapter2Scale,
                      () => _onButtonTap('chapter2'),
                  screenWidth,
                  screenHeight,
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
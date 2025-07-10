import 'package:flutter/material.dart';
import 'audio_manager.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  double _audioScale = 1.0;
  double _languageScale = 1.0;
  double _backScale = 1.0;

  void _onButtonTap(String buttonName) {
    // Play sound effect
    AudioManager().playSfx();

    setState(() {
      switch (buttonName) {
        case 'audio':
          _audioScale = 1.1;
          break;
        case 'language':
          _languageScale = 1.1;
          break;
        case 'back':
          _backScale = 1.1;
          break;
      }
    });

    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _audioScale = 1.0;
        _languageScale = 1.0;
        _backScale = 1.0;
      });

      if (buttonName == 'back') {
        Navigator.pop(context);
      } else if (buttonName == 'audio') {
        // Add audio settings functionality here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio settings functionality not implemented yet'),
            duration: Duration(seconds: 1),
          ),
        );
      } else if (buttonName == 'language') {
        // Add language settings functionality here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Language settings functionality not implemented yet',
            ),
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

          // Settings button in top left (replacing logo)
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.05,
            child: Image.asset(
              'assets/settings_button.png',
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
                      'SETTINGS',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                );
              },
            ),
          ),

          // Center buttons (Audio and Language)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Audio button
                GestureDetector(
                  onTap: () => _onButtonTap('audio'),
                  child: AnimatedScale(
                    scale: _audioScale,
                    duration: Duration(milliseconds: 100),
                    child: Image.asset(
                      'assets/Audiobutton.png',
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.1,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: screenWidth * 0.6,
                          height: screenHeight * 0.1,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'AUDIO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.05),

                // Language button
                GestureDetector(
                  onTap: () => _onButtonTap('language'),
                  child: AnimatedScale(
                    scale: _languageScale,
                    duration: Duration(milliseconds: 100),
                    child: Image.asset(
                      'assets/Languagebutton.png',
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.1,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: screenWidth * 0.6,
                          height: screenHeight * 0.1,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'LANGUAGE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
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

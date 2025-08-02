import 'package:flutter/material.dart';
import '../managers/audio_manager.dart';
import '../managers/language_manager.dart';

class AudioSettingsScreen extends StatefulWidget {
  const AudioSettingsScreen({super.key});

  @override
  _AudioSettingsScreenState createState() => _AudioSettingsScreenState();
}

class _AudioSettingsScreenState extends State<AudioSettingsScreen> {
  double _sfxVolume = 100.0;
  double _musicVolume = 100.0;
  double _buttonScale = 1.0;
  String _currentLanguage = LanguageManager.currentLanguage;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _loadLanguagePreference();
  }

  Future<void> _initializeAudio() async {
    final audioManager = AudioManager();
    await audioManager.init();
    await audioManager.setVolume('sfx', _sfxVolume / 100);
    await audioManager.setVolume('bgm', _musicVolume / 100);
    if (!audioManager.isBgmPlaying) {
      await audioManager.playBackgroundMusic();
    }
  }

  Future<void> _loadLanguagePreference() async {
    setState(() {
      _currentLanguage = LanguageManager.currentLanguage;
    });
  }

  String _getLocalizedText(String englishText, String vietnameseText) {
    return _currentLanguage == 'Vietnamese' ? vietnameseText : englishText;
  }

  void _onButtonTap(String buttonName) {
    AudioManager().playButtonSound();
    setState(() {
      _buttonScale = 1.1;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _buttonScale = 1.0;
      });
      if (buttonName == 'back') {
        Navigator.pop(context);
      }
    });
  }

  void _updateVolume(String type, double value) {
    setState(() {
      if (type == 'sfx') _sfxVolume = value.clamp(0.0, 100.0);
      if (type == 'bgm') _musicVolume = value.clamp(0.0, 100.0);
    });
    AudioManager().setVolume(type, value / 100);
    if (type == 'bgm') {
      AudioManager().playBackgroundMusic();
    }
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
          Container(
            color: Colors.grey[800],
            child: Image.asset(
              'assets/images/backgrounds/background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey[800]);
              },
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _updateVolume('sfx', _sfxVolume - 10),
                      child: Image.asset(
                        'assets/images/ui/minusbutton.png',
                        width: screenWidth * 0.1,
                        height: screenHeight * 0.06,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      _getLocalizedText(
                        'SFX: ${_sfxVolume.round()}',
                        'HIỆU ỨNG ÂM THANH: ${_sfxVolume.round()}',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Bungee',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
                    SizedBox(width: screenWidth * 0.02),
                    GestureDetector(
                      onTap: () => _updateVolume('sfx', _sfxVolume + 10),
                      child: Image.asset(
                        'assets/images/ui/plusbutton.png',
                        width: screenWidth * 0.1,
                        height: screenHeight * 0.06,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _updateVolume('bgm', _musicVolume - 10),
                      child: Image.asset(
                        'assets/images/ui/minusbutton.png',
                        width: screenWidth * 0.1,
                        height: screenHeight * 0.06,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      _getLocalizedText(
                        'MUSIC: ${_musicVolume.round()}',
                        'NHẠC NỀN: ${_musicVolume.round()}',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Bungee',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
                    SizedBox(width: screenWidth * 0.02),
                    GestureDetector(
                      onTap: () => _updateVolume('bgm', _musicVolume + 10),
                      child: Image.asset(
                        'assets/images/ui/plusbutton.png',
                        width: screenWidth * 0.1,
                        height: screenHeight * 0.06,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.1),
                GestureDetector(
                  onTap: () => _onButtonTap('back'),
                  child: AnimatedScale(
                    scale: _buttonScale,
                    duration: const Duration(milliseconds: 100),
                    child: Image.asset(
                      'assets/images/ui/backbutton.png',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

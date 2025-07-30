import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_manager.dart';
import 'language_manager.dart';
import 'LeaderboardScreen.dart';

class TowerModeScreen extends StatefulWidget {
  const TowerModeScreen({super.key});

  @override
  _TowerModeScreenState createState() => _TowerModeScreenState();
}

class _TowerModeScreenState extends State<TowerModeScreen> {
  double _playButtonScale = 1.0;
  double _backButtonScale = 1.0;
  double _achievementButtonScale = 1.0;

  // Season data
  int _currentSeason = 0;
  DateTime? _seasonEndTime;
  String _countdownText = '';
  Timer? _countdownTimer;
  String _currentLanguage = LanguageManager.currentLanguage;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
    _loadSeasonData();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('language') ?? 'English';
      LanguageManager.setLanguage(_currentLanguage);
    });
  }

  Future<void> _loadSeasonData() async {
    // Mock season data (replace with actual API call if needed)
    final now = DateTime.now();
    final endTime = now.add(Duration(hours: 12)); // Example: 12 hours from now
    setState(() {
      _currentSeason = 0;
      _seasonEndTime = endTime;
    });
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seasonEndTime != null) {
        final now = DateTime.now();
        final difference = _seasonEndTime!.difference(now);

        if (difference.isNegative) {
          _loadSeasonData();
          return;
        }

        setState(() {
          _countdownText = _formatCountdown(difference);
        });
      }
    });

    if (_seasonEndTime != null) {
      final now = DateTime.now();
      final difference = _seasonEndTime!.difference(now);
      setState(() {
        _countdownText = _formatCountdown(difference);
      });
    }
  }

  String _formatCountdown(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours - (days * 24);
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      final dayText = days == 1 ? 'DAY' : 'DAYS';
      final hourText = hours == 1 ? 'HOUR' : 'HOURS';
      return _getLocalizedText(
          '$days $dayText $hours $hourText $minutes M',
          '$days NGÀY $hours GIỜ $minutes PHÚT'
      );
    } else if (hours > 0) {
      final hourText = hours == 1 ? 'HOUR' : 'HOURS';
      return _getLocalizedText(
          '$hours $hourText $minutes M',
          '$hours GIỜ $minutes PHÚT'
      );
    } else {
      return _getLocalizedText(
          '$minutes M',
          '$minutes PHÚT'
      );
    }
  }

  String _getLocalizedText(String englishText, String vietnameseText) {
    return _currentLanguage == 'Vietnamese' ? vietnameseText : englishText;
  }

  void _onButtonTap(String buttonName) {
    AudioManager().playSfx();

    setState(() {
      switch (buttonName) {
        case 'play':
          _playButtonScale = 1.1;
          break;
        case 'back':
          _backButtonScale = 1.1;
          break;
        case 'achievement':
          _achievementButtonScale = 1.1;
          break;
      }
    });

    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _playButtonScale = 1.0;
        _backButtonScale = 1.0;
        _achievementButtonScale = 1.0;
      });

      if (buttonName == 'play') {
        // Navigate to tower game
        Navigator.pushNamed(context, '/tower_game');
      } else if (buttonName == 'back') {
        Navigator.pop(context);
      } else if (buttonName == 'achievement') {
        // Navigate to leaderboard
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LeaderboardScreen()),
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
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.3), // Dark overlay for better text visibility
            ),
          ),

          // Fallback background if image fails to load
          Container(
            color: Colors.grey[800],
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.orange[300]!, Colors.brown[700]!],
                    ),
                  ),
                );
              },
            ),
          ),

          // Tower Mode Title
          Positioned(
            top: screenHeight * 0.08,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/frame.png',
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.10,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: screenWidth * 0.8,
                        height: screenHeight * 0.10,
                        decoration: BoxDecoration(
                          color: Colors.brown[600],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.brown[800]!, width: 3),
                        ),
                      );
                    },
                  ),
                  Text(
                    _getLocalizedText('TOWER MODE', 'CHẾ ĐỘ THÁP'),
                    style: TextStyle(
                      fontFamily: 'Bungee',
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(offset: Offset(-1, -1), color: Colors.black),
                        Shadow(offset: Offset(1, -1), color: Colors.black),
                        Shadow(offset: Offset(-1, 1), color: Colors.black),
                        Shadow(offset: Offset(1, 1), color: Colors.black),
                        Shadow(offset: Offset(0, 0), color: Colors.black, blurRadius: 3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Season Information
          Positioned(
            top: screenHeight * 0.25,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  _getLocalizedText('SEASON $_currentSeason', 'MÙA $_currentSeason'),
                  style: TextStyle(
                    fontFamily: 'Bungee',
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(offset: Offset(2, 2), color: Colors.black, blurRadius: 4),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  _countdownText.isNotEmpty ? _getLocalizedText('RESETS IN: $_countdownText', 'RESET TRONG: $_countdownText') : _getLocalizedText('RESETS IN: 12 HOURS 4 HOURS', 'RESET TRONG: 12 GIỜ 4 GIỜ'),
                  style: TextStyle(
                    fontFamily: 'Bungee',
                    fontSize: screenWidth * 0.035,
                    color: Colors.white,
                    shadows: [
                      Shadow(offset: Offset(1, 1), color: Colors.black, blurRadius: 2),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Play Button
          Positioned(
            top: screenHeight * 0.45,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _onButtonTap('play'),
                child: AnimatedScale(
                  scale: _playButtonScale,
                  duration: Duration(milliseconds: 100),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/frame.png',
                        width: screenWidth * 0.6, // Increased from 0.5 to 0.6
                        height: screenHeight * 0.10, // Increased from 0.08 to 0.10
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: screenWidth * 0.6,
                            height: screenHeight * 0.10,
                            decoration: BoxDecoration(
                              color: Colors.brown[600],
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.brown[800]!, width: 3),
                            ),
                          );
                        },
                      ),
                      Text(
                        _getLocalizedText('PLAY', 'CHƠI'),
                        style: TextStyle(
                          fontFamily: 'Bungee',
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(offset: Offset(-1, -1), color: Colors.black),
                            Shadow(offset: Offset(1, -1), color: Colors.black),
                            Shadow(offset: Offset(-1, 1), color: Colors.black),
                            Shadow(offset: Offset(1, 1), color: Colors.black),
                            Shadow(offset: Offset(0, 0), color: Colors.black, blurRadius: 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Record Information
          Positioned(
            top: screenHeight * 0.58,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _getLocalizedText('RECORD: LEVEL 42', 'KỶ LỤC: CẤP 42'),
                style: TextStyle(
                  fontFamily: 'Bungee',
                  fontSize: screenWidth * 0.04,
                  color: Colors.white,
                  shadows: [
                    Shadow(offset: Offset(1, 1), color: Colors.black, blurRadius: 2),
                  ],
                ),
              ),
            ),
          ),

          // Achievement/Trophy Button
          Positioned(
            bottom: screenHeight * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _onButtonTap('achievement'),
                child: AnimatedScale(
                  scale: _achievementButtonScale,
                  duration: Duration(milliseconds: 100),
                  child: Column(
                    children: [
                      Container(
                        width: screenWidth * 0.15,
                        height: screenWidth * 0.15,
                        decoration: BoxDecoration(
                          color: Colors.brown[600],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.brown[800]!, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/trophy.png',
                          width: screenWidth * 0.08,
                          height: screenWidth * 0.08,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.error,
                              color: Colors.red,
                              size: screenWidth * 0.08,
                            );
                          },
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        _getLocalizedText('LEADERBOARD', 'BẢNG XẾP HẠNG'),
                        style: TextStyle(
                          fontFamily: 'Bungee',
                          fontSize: screenWidth * 0.025,
                          color: Colors.white,
                          shadows: [
                            Shadow(offset: Offset(1, 1), color: Colors.black, blurRadius: 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Back Button
          Positioned(
            bottom: screenHeight * 0.03,
            right: screenWidth * 0.04,
            child: GestureDetector(
              onTap: () => _onButtonTap('back'),
              child: AnimatedScale(
                scale: _backButtonScale,
                duration: Duration(milliseconds: 100),
                child: Image.asset(
                  'assets/backbutton.png',
                  width: screenWidth * 0.18,
                  height: screenWidth * 0.18,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: screenWidth * 0.12,
                      height: screenWidth * 0.12,
                      decoration: BoxDecoration(
                        color: Colors.brown[600],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.brown[800]!, width: 3),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: screenWidth * 0.06,
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
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../managers/audio_manager.dart';
import '../managers/language_manager.dart';
import '../managers/game_manager.dart';
import 'LeaderboardScreen.dart';
import 'TowerGameplayScreen.dart';
import 'login_screen.dart';

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
  Timer? _countdownTimer;
  String _currentLanguage = LanguageManager.currentLanguage;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
    _initializeData();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLanguagePreference() async {
    // Language preference can be handled by LanguageManager
    setState(() {
      _currentLanguage = LanguageManager.currentLanguage;
    });
  }

  Future<void> _initializeData() async {
    final gameManager = context.read<GameManager>();
    await gameManager.loadSeasonData();
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      final gameManager = context.read<GameManager>();
      if (gameManager.seasonEndTime != null) {
        final now = DateTime.now();
        final difference = gameManager.seasonEndTime!.difference(now);

        if (difference.isNegative) {
          // Season ended, reload season data to start new season
          await gameManager.loadSeasonData();
          return;
        }

        // Trigger rebuild through setState
        setState(() {});
      }
    });
  }

  String _getLocalizedText(String englishText, String vietnameseText) {
    return _currentLanguage == 'Vietnamese' ? vietnameseText : englishText;
  }

  void _onButtonTap(String buttonName) {
    AudioManager().playButtonSound();

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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TowerGameplayScreen()),
        );
      } else if (buttonName == 'back') {
        Navigator.pop(context);
      } else if (buttonName == 'achievement') {
        // Check if player is logged in before accessing leaderboard
        final gameManager = Provider.of<GameManager>(context, listen: false);
        if (gameManager.isGuestMode) {
          // Navigate to login screen if not logged in
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          // Navigate to leaderboard if logged in
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LeaderboardScreen()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Consumer<GameManager>(
      builder: (context, gameManager, child) {
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/backgrounds/background.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  color: Colors.black.withOpacity(
                    0.3,
                  ), // Dark overlay for better text visibility
                ),
              ),

              // Fallback background if image fails to load
              Container(
                color: Colors.grey[800],
                child: Image.asset(
                  'assets/images/backgrounds/background.png',
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
                        'assets/images/ui/frame.png',
                        width: screenWidth * 0.8,
                        height: screenHeight * 0.10,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: screenWidth * 0.8,
                            height: screenHeight * 0.10,
                            decoration: BoxDecoration(
                              color: Colors.brown[600],
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.brown[800]!,
                                width: 3,
                              ),
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
                            Shadow(
                              offset: Offset(0, 0),
                              color: Colors.black,
                              blurRadius: 3,
                            ),
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
                      _getLocalizedText(
                        'SEASON ${gameManager.currentSeason}',
                        'MÙA ${gameManager.currentSeason}',
                      ),
                      style: TextStyle(
                        fontFamily: 'Bungee',
                        fontSize: screenWidth * 0.08,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            color: Colors.black,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      gameManager.seasonEndTime != null
                          ? _getLocalizedText(
                              'RESETS IN: ${gameManager.getCountdownText()}',
                              'RESET TRONG: ${gameManager.getCountdownText()}',
                            )
                          : _getLocalizedText(
                              'RESETS IN: Loading...',
                              'RESET TRONG: Đang tải...',
                            ),
                      style: TextStyle(
                        fontFamily: 'Bungee',
                        fontSize: screenWidth * 0.035,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            color: Colors.black,
                            blurRadius: 2,
                          ),
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
                            'assets/images/ui/frame.png',
                            width:
                                screenWidth * 0.6, // Increased from 0.5 to 0.6
                            height:
                                screenHeight *
                                0.10, // Increased from 0.08 to 0.10
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: screenWidth * 0.6,
                                height: screenHeight * 0.10,
                                decoration: BoxDecoration(
                                  color: Colors.brown[600],
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.brown[800]!,
                                    width: 3,
                                  ),
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
                                Shadow(
                                  offset: Offset(-1, -1),
                                  color: Colors.black,
                                ),
                                Shadow(
                                  offset: Offset(1, -1),
                                  color: Colors.black,
                                ),
                                Shadow(
                                  offset: Offset(-1, 1),
                                  color: Colors.black,
                                ),
                                Shadow(
                                  offset: Offset(1, 1),
                                  color: Colors.black,
                                ),
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
                ),
              ),

              // Record Information
              Positioned(
                top: screenHeight * 0.58,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    gameManager.isGuestMode
                        ? _getLocalizedText(
                            'Log in to see tower record',
                            'Đăng nhập để xem kỷ lục tháp',
                          )
                        : _getLocalizedText(
                            'RECORD: LEVEL ${gameManager.currentPlayer?.towerRecord ?? 0}',
                            'KỶ LỤC: CẤP ${gameManager.currentPlayer?.towerRecord ?? 0}',
                          ),
                    style: TextStyle(
                      fontFamily: 'Bungee',
                      fontSize: screenWidth * 0.04,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          color: Colors.black,
                          blurRadius: 2,
                        ),
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
                              border: Border.all(
                                color: Colors.brown[800]!,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/items/trophy.png',
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
                                Shadow(
                                  offset: Offset(1, 1),
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
                      'assets/images/ui/backbutton.png',
                      width: screenWidth * 0.18,
                      height: screenWidth * 0.18,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: screenWidth * 0.12,
                          height: screenWidth * 0.12,
                          decoration: BoxDecoration(
                            color: Colors.brown[600],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.brown[800]!,
                              width: 3,
                            ),
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
      },
    );
  }
}

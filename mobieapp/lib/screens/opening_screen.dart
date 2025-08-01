import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/audio_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../managers/language_manager.dart';
import '../managers/game_manager.dart';
import 'dart:async';

class OpeningScreen extends StatefulWidget {
  const OpeningScreen({super.key});

  @override
  _OpeningScreenState createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen>
    with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;
  String _currentLanguage = LanguageManager.currentLanguage;
  bool _showLoginPopup = false;

  @override
  void initState() {
    super.initState();

    // Initialize and start background music
    _initAudio();

    _buttonController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _buttonAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
    _buttonController.forward();

    _loadLanguagePreference();
    _checkFirstLaunch();
  }

  Future<void> _initAudio() async {
    try {
      await AudioManager().init();
      await AudioManager().playBackgroundMusic();
      print('Audio initialized successfully in OpeningScreen');

      // Remove external BGM checking since AudioManager now has internal monitoring
      // _bgmCheckTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      //   AudioManager().ensureBgmPlaying();
      // });
    } catch (e) {
      print('Error initializing audio: $e');
    }
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('language') ?? 'English';
      LanguageManager.setLanguage(_currentLanguage);
    });
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('first_launch') ?? true;

    if (isFirstLaunch) {
      setState(() {
        _showLoginPopup = true;
      });
    }
  }

  Future<void> _setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
  }

  String _getLocalizedText(String englishText, String vietnameseText) {
    return _currentLanguage == 'Vietnamese' ? vietnameseText : englishText;
  }

  void _handleLogin() {
    // Navigate to dedicated login screen for database authentication
    AudioManager().playButtonSound();
    Navigator.pushNamed(context, '/login');
  }

  void _handleRegister() {
    // Navigate to dedicated login screen in register mode
    AudioManager().playButtonSound();
    Navigator.pushNamed(context, '/login');
  }

  Widget _buildFramedButton(
    String text,
    VoidCallback onTap,
    double width,
    double height,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/ui/frame.png',
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.brown[600],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.brown[800]!, width: 2),
                ),
              );
            },
          ),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Bungee',
              fontSize: width * 0.08,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(offset: Offset(-1, -1), color: Colors.black),
                Shadow(offset: Offset(1, -1), color: Colors.black),
                Shadow(offset: Offset(-1, 1), color: Colors.black),
                Shadow(offset: Offset(1, 1), color: Colors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPopup() {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: screenWidth * 0.85,
        height: screenHeight * 0.7,
        decoration: BoxDecoration(
          color: Colors.brown[800],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.brown[900]!, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                _getLocalizedText('WELCOME', 'CHÀO MỪNG'),
                style: TextStyle(
                  fontFamily: 'Bungee',
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(offset: Offset(-1, -1), color: Colors.black),
                    Shadow(offset: Offset(1, -1), color: Colors.black),
                    Shadow(offset: Offset(-1, 1), color: Colors.black),
                    Shadow(offset: Offset(1, 1), color: Colors.black),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Username field
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  _getLocalizedText(
                    'Login to save your progress and compete with friends!',
                    'Đăng nhập để lưu tiến trình và thi đấu với bạn bè!',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ),

              SizedBox(height: 25),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Login button
                  _buildFramedButton(
                    _getLocalizedText('LOGIN', 'ĐĂNG NHẬP'),
                    _handleLogin,
                    screenWidth * 0.3,
                    screenHeight * 0.08,
                  ),

                  // Register button
                  _buildFramedButton(
                    _getLocalizedText('REGISTER', 'ĐĂNG KÝ'),
                    _handleRegister,
                    screenWidth * 0.3,
                    screenHeight * 0.08,
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Skip button
              _buildFramedButton(
                _getLocalizedText('PLAY AS GUEST', 'CHƠI VỚI TƯ CÁCH KHÁCH'),
                () {
                  AudioManager().playButtonSound();
                  // Enable guest mode in GameManager
                  final gameManager = Provider.of<GameManager>(context, listen: false);
                  gameManager.enableGuestMode();
                  
                  _setFirstLaunchComplete();
                  setState(() {
                    _showLoginPopup = false;
                  });
                },
                screenWidth * 0.25,
                screenHeight * 0.06,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () {
              if (!_showLoginPopup) {
                AudioManager().playButtonSound();
                Navigator.pushNamed(context, '/main_menu');
              }
            },
            child: Stack(
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
                Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: Center(
                    child: Image.asset(
                      'assets/images/ui/logo.png',
                      width: 650,
                      height: 485,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 650,
                          height: 485,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ),
                if (!_showLoginPopup)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 50.0),
                      child: ScaleTransition(
                        scale: _buttonAnimation,
                        child: Text(
                          _getLocalizedText(
                            'PRESS TO CONTINUE',
                            'ẤN ĐỂ TIẾP TỤC',
                          ),
                          style: TextStyle(
                            fontFamily: 'Bungee',
                            fontSize: 30,
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
                              Shadow(offset: Offset(1, 1), color: Colors.black),
                              Shadow(
                                offset: Offset(0, 0),
                                color: Colors.black,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Login popup overlay
          if (_showLoginPopup)
            Container(
              color: Colors.black54,
              child: Center(child: _buildLoginPopup()),
            ),
        ],
      ),
    );
  }
}

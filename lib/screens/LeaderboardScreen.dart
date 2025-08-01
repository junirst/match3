import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../managers/audio_manager.dart';
import '../managers/language_manager.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  double _backButtonScale = 1.0;
  String _currentLanguage = LanguageManager.currentLanguage;
  List<Map<String, dynamic>> _players = [];
  bool _isLoading = true;

  // Season data
  int _currentSeason = 0;
  DateTime? _seasonEndTime;
  String _countdownText = '';
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
    _loadSeasonData();
    _loadLeaderboardData();
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
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // Get stored season data or initialize
    int storedSeason = prefs.getInt('current_season') ?? 0;
    String? storedEndTimeString = prefs.getString('season_end_time');

    DateTime seasonEndTime;

    if (storedEndTimeString != null) {
      // If we have stored data, use it
      seasonEndTime = DateTime.parse(storedEndTimeString);

      // Check if current season has ended
      if (now.isAfter(seasonEndTime)) {
        // Season has ended, start new season
        storedSeason += 1;
        seasonEndTime = _getNextSeasonEndTime(now);

        // Save new season data
        await prefs.setInt('current_season', storedSeason);
        await prefs.setString('season_end_time', seasonEndTime.toIso8601String());
      }
    } else {
      // First time setup - start from tomorrow 4 AM
      seasonEndTime = _getNextSeasonEndTime(now);

      // Save initial season data
      await prefs.setInt('current_season', storedSeason);
      await prefs.setString('season_end_time', seasonEndTime.toIso8601String());
    }

    setState(() {
      _currentSeason = storedSeason;
      _seasonEndTime = seasonEndTime;
    });

    _startCountdownTimer();
  }

  DateTime _getNextSeasonEndTime(DateTime currentTime) {
    // Calculate next 4 AM (tomorrow if it's already past 4 AM today, or today if it's before 4 AM)
    DateTime next4AM = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      4, // 4 AM
      0, // 0 minutes
      0, // 0 seconds
    );

    // If it's already past 4 AM today, move to tomorrow
    if (currentTime.isAfter(next4AM)) {
      next4AM = next4AM.add(Duration(days: 1));
    }

    // Add 21 days for season duration
    return next4AM.add(Duration(days: 21));
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (_seasonEndTime != null) {
        final now = DateTime.now();
        final difference = _seasonEndTime!.difference(now);

        if (difference.isNegative) {
          // Season ended, reload season data to start new season
          await _loadSeasonData();
          return;
        }

        setState(() {
          _countdownText = _formatCountdown(difference);
        });
      }
    });

    // Set initial countdown text
    if (_seasonEndTime != null) {
      final now = DateTime.now();
      final difference = _seasonEndTime!.difference(now);
      if (!difference.isNegative) {
        setState(() {
          _countdownText = _formatCountdown(difference);
        });
      }
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

  Future<void> _loadLeaderboardData() async {
    // Mock API call
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    setState(() {
      _players = _getMockPlayers();
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _getMockPlayers() {
    return [
      {'name': 'EliteGamer', 'level': 50},
      {'name': 'ShadowKing', 'level': 42},
      {'name': 'TowerMaster', 'level': 35},
      {'name': 'SkyWalker', 'level': 28},
      {'name': 'IronClad', 'level': 20},
    ];
  }

  String _getLocalizedText(String englishText, String vietnameseText) {
    return _currentLanguage == 'Vietnamese' ? vietnameseText : englishText;
  }

  void _onButtonTap(String buttonName) {
    AudioManager().playButtonSound();

    setState(() {
      switch (buttonName) {
        case 'back':
          _backButtonScale = 1.1;
          break;
      }
    });

    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _backButtonScale = 1.0;
      });

      if (buttonName == 'back') {
        Navigator.pop(context);
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
                image: AssetImage('assets/images/backgrounds/background.png'),
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

          // Leaderboard Title with Frame
          Positioned(
            top: screenHeight * 0.02,
            left: screenWidth * 0.05,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/ui/frame.png',
                  width: screenWidth * 0.9, // Adjusted width to fit localization
                  height: screenHeight * 0.12,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.12,
                      decoration: BoxDecoration(
                        color: Colors.brown[600],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.brown[800]!, width: 3),
                      ),
                    );
                  },
                ),
                Text(
                  _getLocalizedText('LEADERBOARD', 'BẢNG XẾP HẠNG'),
                  style: TextStyle(
                    fontFamily: 'Bungee',
                    fontSize: screenWidth * 0.06, // Increased size
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

          // Season Information
          Positioned(
            top: screenHeight * 0.16,
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
                  _countdownText.isNotEmpty ? _getLocalizedText('RESETS IN: $_countdownText', 'RESET TRONG: $_countdownText') : _getLocalizedText('LOADING...', 'ĐANG TẢI...'),
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

          // Player List
          Positioned(
            top: screenHeight * 0.30,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            bottom: screenHeight * 0.15,
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.white))
                : ListView.builder(
              itemCount: _players.length,
              itemBuilder: (context, index) {
                final player = _players[index];
                final isTopPlayer = index == 0;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        isTopPlayer ? 'assets/images/characters/topplayer.png' : 'assets/images/characters/player.png',
                        width: screenWidth * 0.12,
                        height: screenHeight * 0.08,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            color: isTopPlayer ? Colors.amber : Colors.white,
                            size: screenWidth * 0.12,
                          );
                        },
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Text(
                        player['name'],
                        style: TextStyle(
                          fontFamily: 'Bungee',
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(offset: Offset(1, 1), color: Colors.black, blurRadius: 2),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Text(
                        _getLocalizedText('LEVEL ${player['level']}', 'CẤP ${player['level']}'),
                        style: TextStyle(
                          fontFamily: 'Bungee',
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(offset: Offset(1, 1), color: Colors.black, blurRadius: 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
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

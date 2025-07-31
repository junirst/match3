import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../managers/audio_manager.dart';
import '../managers/language_manager.dart';

class PlayerProfileScreen extends StatefulWidget {
  const PlayerProfileScreen({super.key});

  @override
  _PlayerProfileScreenState createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  double _backScale = 1.0;
  String _currentLanguage = LanguageManager.currentLanguage;
  String _playerName = 'PLAYER NAME';
  String _playerId = 'PL123456';
  String _selectedGender = 'Male';
  int _towerRecord = 42;

  // Upgrade levels from UpgradeInside
  Map<String, int> upgradeLevels = {
    'sword': 1,
    'heart': 1,
    'star': 1,
    'shield': 1,
  };

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
    _loadPlayerData();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('language') ?? 'English';
      LanguageManager.setLanguage(_currentLanguage);
    });
  }

  Future<void> _loadPlayerData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _playerName = prefs.getString('player_name') ?? 'PLAYER NAME';
      _playerId = prefs.getString('player_id') ?? 'PL123456';
      _selectedGender = prefs.getString('player_gender') ?? 'Male';
      _towerRecord = prefs.getInt('tower_record') ?? 42;

      // Load upgrade levels
      upgradeLevels['sword'] = prefs.getInt('upgrade_sword_level') ?? 1;
      upgradeLevels['heart'] = prefs.getInt('upgrade_heart_level') ?? 1;
      upgradeLevels['star'] = prefs.getInt('upgrade_star_level') ?? 1;
      upgradeLevels['shield'] = prefs.getInt('upgrade_shield_level') ?? 1;
    });
  }

  Future<void> _saveGender(String gender) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player_gender', gender);
    setState(() {
      _selectedGender = gender;
    });
  }

  String _getLocalizedText(String englishText, String vietnameseText) {
    return _currentLanguage == 'Vietnamese' ? vietnameseText : englishText;
  }

  String _getLocalizedGender(String gender) {
    if (_currentLanguage == 'Vietnamese') {
      switch (gender) {
        case 'Male':
          return 'Nam';
        case 'Female':
          return 'Nữ';
        case 'Other':
          return 'Khác';
        default:
          return gender;
      }
    }
    return gender;
  }

  void _onBackTap() {
    AudioManager().playButtonSound();
    setState(() {
      _backScale = 1.1;
    });
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _backScale = 1.0;
      });
      Navigator.pop(context);
    });
  }

  Widget _buildInfoSection(String title, String value, double screenWidth) {
    return Container(
      width: screenWidth * 0.85,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.03,
      ),
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Bungee',
              fontSize: screenWidth * 0.04,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  color: Colors.black,
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Bungee',
              fontSize: screenWidth * 0.04,
              color: Colors.white,
              fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildGenderSelector(double screenWidth) {
    return Container(
      width: screenWidth * 0.85,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.03,
      ),
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getLocalizedText('GENDER:', 'GIỚI TÍNH:'),
            style: TextStyle(
              fontFamily: 'Bungee',
              fontSize: screenWidth * 0.04,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  color: Colors.black,
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: _selectedGender,
            dropdownColor: Colors.black.withOpacity(0.8),
            style: TextStyle(
              fontFamily: 'Bungee',
              fontSize: screenWidth * 0.04,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            underline: Container(),
            items: _genderOptions.map((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(
                  _getLocalizedGender(gender),
                  style: TextStyle(
                    fontFamily: 'Bungee',
                    fontSize: screenWidth * 0.04,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                _saveGender(newValue);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeRow(String upgradeType, String iconPath, Color color, double screenWidth) {
    return Container(
      width: screenWidth * 0.85,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.025,
      ),
      margin: EdgeInsets.only(bottom: screenWidth * 0.02),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth * 0.12,
            height: screenWidth * 0.12,
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(screenWidth * 0.06),
            ),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Image.asset(
                iconPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.inventory,
                    color: Colors.white,
                    size: screenWidth * 0.08,
                  );
                },
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Text(
              upgradeType.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Bungee',
                fontSize: screenWidth * 0.04,
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
          Text(
            'LVL ${upgradeLevels[upgradeType]}',
            style: TextStyle(
              fontFamily: 'Bungee',
              fontSize: screenWidth * 0.04,
              color: Colors.white,
              fontWeight: FontWeight.bold,
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
          Container(
            color: Colors.grey[800],
            child: Image.asset(
              'assets/images/backgrounds/background.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.08),
                // Title
                Text(
                  _getLocalizedText('PLAYER PROFILE', 'HỒ SƠ NGƯỜI CHƠI'),
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
                SizedBox(height: screenHeight * 0.03),
                // Player Avatar
                CircleAvatar(
                  radius: screenWidth * 0.15,
                  backgroundImage: AssetImage('assets/images/characters/player.png'),
                ),
                SizedBox(height: screenHeight * 0.02),
                // Player Name - Keep DistilleryDisplay font
                Text(
                  _playerName,
                  style: TextStyle(
                    fontFamily: 'DistilleryDisplay',
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
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
                SizedBox(height: screenHeight * 0.04),
                // Player Information
                _buildInfoSection(
                  _getLocalizedText('PLAYER ID:', 'ID NGƯỜI CHƠI:'),
                  _playerId,
                  screenWidth,
                ),
                _buildGenderSelector(screenWidth),
                _buildInfoSection(
                  _getLocalizedText('TOWER RECORD:', 'KỶ LỤC THÁP:'),
                  _getLocalizedText('LEVEL $_towerRecord', 'CẤP $_towerRecord'),
                  screenWidth,
                ),
                SizedBox(height: screenHeight * 0.02),
                // Upgrades Section Title
                Text(
                  _getLocalizedText('UPGRADES', 'NÂNG CẤP'),
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
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                // Upgrade Levels
                _buildUpgradeRow('sword', 'assets/images/items/sword.png', Colors.red, screenWidth),
                _buildUpgradeRow('heart', 'assets/images/items/heart.png', Colors.green, screenWidth),
                _buildUpgradeRow('star', 'assets/images/items/star.png', Colors.yellow, screenWidth),
                _buildUpgradeRow('shield', 'assets/images/items/shield.png', Colors.blue, screenWidth),
                SizedBox(height: screenHeight * 0.15),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: screenHeight * 0.03,
                right: screenWidth * 0.02,
              ),
              child: GestureDetector(
                onTap: _onBackTap,
                child: AnimatedScale(
                  scale: _backScale,
                  duration: Duration(milliseconds: 100),
                  child: Image.asset(
                    'assets/images/ui/back_button.png',
                    width: screenWidth * 0.18,
                    height: screenHeight * 0.18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

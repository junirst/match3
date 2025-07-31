import 'package:flutter/material.dart';
import 'main_menu_screen.dart';
import 'ShopInside.dart';
import 'audio_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_manager.dart';

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
  bool _showRegisterForm = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Start background music
    AudioManager().playBackgroundMusic();

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

  @override
  void dispose() {
    _buttonController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _confirmPasswordController.dispose();
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
    // Handle login logic here
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      AudioManager().playSfx();
      _setFirstLaunchComplete();
      setState(() {
        _showLoginPopup = false;
      });
      // You can add actual authentication logic here
    }
  }

  void _handleRegister() {
    // Handle registration logic here
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (username.isNotEmpty && email.isNotEmpty &&
        password.isNotEmpty && password == confirmPassword) {
      AudioManager().playSfx();
      _setFirstLaunchComplete();
      setState(() {
        _showLoginPopup = false;
        _showRegisterForm = false;
      });
      // You can add actual registration logic here
    }
  }

  Widget _buildFramedButton(String text, VoidCallback onTap, double width, double height) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/frame.png',
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
                _showRegisterForm
                    ? _getLocalizedText('REGISTER', 'ĐĂNG KÝ')
                    : _getLocalizedText('LOGIN', 'ĐĂNG NHẬP'),
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
              TextField(
                controller: _usernameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: _getLocalizedText('Username', 'Tên đăng nhập'),
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown[300]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              SizedBox(height: 15),

              // Email field (only for register)
              if (_showRegisterForm) ...[
                TextField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: _getLocalizedText('Email', 'Email'),
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown[300]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 15),
              ],

              // Password field
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: _getLocalizedText('Password', 'Mật khẩu'),
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown[300]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              SizedBox(height: 15),

              // Confirm Password field (only for register)
              if (_showRegisterForm) ...[
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: _getLocalizedText('Confirm Password', 'Xác nhận mật khẩu'),
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown[300]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 25),
              ],

              SizedBox(height: 25),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Main action button (Login/Register)
                  _buildFramedButton(
                    _showRegisterForm
                        ? _getLocalizedText('REGISTER', 'ĐĂNG KÝ')
                        : _getLocalizedText('LOGIN', 'ĐĂNG NHẬP'),
                    _showRegisterForm ? _handleRegister : _handleLogin,
                    screenWidth * 0.3,
                    screenHeight * 0.08,
                  ),

                  // Toggle button (Register/Back to Login)
                  _buildFramedButton(
                    _showRegisterForm
                        ? _getLocalizedText('BACK', 'QUAY LẠI')
                        : _getLocalizedText('REGISTER', 'ĐĂNG KÝ'),
                        () {
                      AudioManager().playSfx();
                      setState(() {
                        _showRegisterForm = !_showRegisterForm;
                        // Clear form fields when switching
                        _usernameController.clear();
                        _passwordController.clear();
                        _emailController.clear();
                        _confirmPasswordController.clear();
                      });
                    },
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
                  AudioManager().playSfx();
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
                AudioManager().playSfx();
                Navigator.pushNamed(context, '/main_menu');
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
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
                Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: Center(
                    child: Image.asset(
                      'assets/logo.png',
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
                          _getLocalizedText('PRESS TO CONTINUE', 'ẤN ĐỂ TIẾP TỤC'),
                          style: TextStyle(
                            fontFamily: 'Bungee',
                            fontSize: 30,
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
              child: Center(
                child: _buildLoginPopup(),
              ),
            ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/game_manager.dart';
import '../managers/audio_manager.dart';
import '../managers/language_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final bool startInCreateMode;

  const LoginScreen({super.key, this.startInCreateMode = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _playerNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isCreateMode = false;
  String? _selectedGender;
  String? _selectedLanguage;
  String _currentLanguage = LanguageManager.currentLanguage;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _languages = ['English', 'Vietnamese', 'Japanese'];

  // Button scales for animations
  double _backButtonScale = 1.0;

  @override
  void initState() {
    super.initState();
    _isCreateMode = widget.startInCreateMode;
    _loadLanguagePreference();
    
    // Pre-fill test credentials for easier testing
    _emailController.text = 'test@example.com';
    _passwordController.text = '123456';
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('language') ?? 'English';
      LanguageManager.setLanguage(_currentLanguage);
    });
  }

  String _getLocalizedText(String englishText, String vietnameseText) {
    return _currentLanguage == 'Vietnamese' ? vietnameseText : englishText;
  }

  void _onButtonTap(String buttonName) {
    AudioManager().playButtonSound();
    
    setState(() {
      if (buttonName == 'back') {
        _backButtonScale = 1.1;
      }
    });
    
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _backButtonScale = 1.0;
      });
      
      if (buttonName == 'back') {
        Navigator.pop(context);
      } else if (buttonName == 'login') {
        _handleLogin();
      } else if (buttonName == 'register') {
        _handleRegister();
      } else if (buttonName == 'guest') {
        _handleGuestMode();
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final gameManager = Provider.of<GameManager>(context, listen: false);
    
    // Debug info
    print('Attempting login with email: ${_emailController.text.trim()}');
    
    final success = await gameManager.loginPlayer(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        print('Login successful, navigating to main menu');
        Navigator.pushReplacementNamed(context, '/main_menu');
      } else {
        print('Login failed: ${gameManager.error}');
        _showErrorDialog(gameManager.error ?? 'Login failed. Please check your credentials and try again.');
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final gameManager = Provider.of<GameManager>(context, listen: false);
    
    // Store email and password for later use
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    
    final success = await gameManager.registerPlayer(
      playerName: _playerNameController.text.trim(),
      password: password,
      email: email.isEmpty ? null : email,
      gender: _selectedGender,
      languagePreference: _selectedLanguage,
    );

    if (mounted) {
      if (success) {
        _showSuccessDialog('Account created successfully! Please login.');
        setState(() {
          _isCreateMode = false;
          // Keep email and password for login
          _emailController.text = email;
          _passwordController.text = password;
          // Clear only register-specific fields
          _playerNameController.clear();
          _selectedGender = null;
          _selectedLanguage = null;
        });
      } else {
        _showErrorDialog(gameManager.error ?? 'Registration failed');
      }
    }
  }

  void _handleGuestMode() {
    final gameManager = Provider.of<GameManager>(context, listen: false);
    gameManager.enableGuestMode();
    Navigator.pushReplacementNamed(context, '/main_menu');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text(
            _getLocalizedText('Error', 'Lỗi'),
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: Text(
                _getLocalizedText('OK', 'Đồng ý'),
                style: const TextStyle(color: Colors.blue),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text(
            _getLocalizedText('Success', 'Thành công'),
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: Text(
                _getLocalizedText('OK', 'Đồng ý'),
                style: const TextStyle(color: Colors.blue),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModeButton(String text, bool isSelected, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.blue),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      style: const TextStyle(color: Colors.white),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.blue),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      dropdownColor: Colors.grey[800],
      style: const TextStyle(color: Colors.white),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSubmitButton(GameManager gameManager) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: gameManager.isLoading
            ? null
            : _isCreateMode 
                ? () => _onButtonTap('register')
                : () => _onButtonTap('login'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: gameManager.isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : Text(
                _isCreateMode
                    ? _getLocalizedText('CREATE ACCOUNT', 'TẠO TÀI KHOẢN')
                    : _getLocalizedText('LOGIN', 'ĐĂNG NHẬP'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            color: Colors.grey[800],
            child: Image.asset(
              'assets/images/backgrounds/background.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          
          // Back button
          Positioned(
            top: 40,
            left: 20,
            child: Transform.scale(
              scale: _backButtonScale,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: () => _onButtonTap('back'),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Consumer<GameManager>(
                builder: (context, gameManager, child) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.1),
                        
                        // Game Logo
                        Image.asset(
                          'assets/images/ui/logo.png',
                          width: screenWidth * 0.8,
                          height: screenHeight * 0.2,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Title
                        Text(
                          _getLocalizedText('WELCOME', 'CHÀO MỪNG'),
                          style: TextStyle(
                            fontFamily: 'DistilleryDisplay',
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                offset: Offset(1, 1),
                                color: Colors.black,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Form container with background
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.blue.withOpacity(0.5)),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Mode Toggle
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildModeButton(
                                      _getLocalizedText('LOGIN', 'ĐĂNG NHẬP'), 
                                      !_isCreateMode, 
                                      () => setState(() => _isCreateMode = false)
                                    ),
                                    const Text(
                                      ' | ',
                                      style: TextStyle(color: Colors.white, fontSize: 18),
                                    ),
                                    _buildModeButton(
                                      _getLocalizedText('REGISTER', 'ĐĂNG KÝ'), 
                                      _isCreateMode, 
                                      () => setState(() => _isCreateMode = true)
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Player Name (only for register)
                                if (_isCreateMode) ...[
                                  _buildTextField(
                                    controller: _playerNameController,
                                    label: _getLocalizedText('Player Name', 'Tên người chơi'),
                                    icon: Icons.person,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return _getLocalizedText('Please enter player name', 'Vui lòng nhập tên người chơi');
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                ],
                                
                                // Email
                                _buildTextField(
                                  controller: _emailController,
                                  label: _getLocalizedText('Email', 'Email'),
                                  icon: Icons.email,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return _getLocalizedText('Please enter email', 'Vui lòng nhập email');
                                    }
                                    if (!value.contains('@')) {
                                      return _getLocalizedText('Please enter valid email', 'Vui lòng nhập email hợp lệ');
                                    }
                                    return null;
                                  },
                                ),
                                
                                const SizedBox(height: 15),
                                
                                // Password
                                _buildTextField(
                                  controller: _passwordController,
                                  label: _getLocalizedText('Password', 'Mật khẩu'),
                                  icon: Icons.lock,
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return _getLocalizedText('Please enter password', 'Vui lòng nhập mật khẩu');
                                    }
                                    if (value.length < 6) {
                                      return _getLocalizedText('Password must be at least 6 characters', 'Mật khẩu phải có ít nhất 6 ký tự');
                                    }
                                    return null;
                                  },
                                ),
                                
                                // Additional fields for register
                                if (_isCreateMode) ...[
                                  const SizedBox(height: 15),
                                  
                                  // Gender dropdown
                                  _buildDropdown(
                                    value: _selectedGender,
                                    label: _getLocalizedText('Gender (Optional)', 'Giới tính (Tùy chọn)'),
                                    icon: Icons.people,
                                    items: _genders,
                                    onChanged: (value) => setState(() => _selectedGender = value),
                                  ),
                                  
                                  const SizedBox(height: 15),
                                  
                                  // Language dropdown
                                  _buildDropdown(
                                    value: _selectedLanguage,
                                    label: _getLocalizedText('Language (Optional)', 'Ngôn ngữ (Tùy chọn)'),
                                    icon: Icons.language,
                                    items: _languages,
                                    onChanged: (value) => setState(() => _selectedLanguage = value),
                                  ),
                                ],
                                
                                const SizedBox(height: 30),
                                
                                // Submit Button
                                _buildSubmitButton(gameManager),
                                
                                const SizedBox(height: 15),
                                
                                // Mode toggle buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildModeButton(
                                        _getLocalizedText('LOGIN', 'ĐĂNG NHẬP'),
                                        !_isCreateMode,
                                        () => setState(() => _isCreateMode = false),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildModeButton(
                                        _getLocalizedText('CREATE', 'TẠO MỚI'),
                                        _isCreateMode,
                                        () => setState(() => _isCreateMode = true),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 15),
                                
                                // Guest Mode Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 45,
                                  child: OutlinedButton(
                                    onPressed: () => _onButtonTap('guest'),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.amber, width: 2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      _getLocalizedText('PLAY AS GUEST', 'CHƠI VỚI TƯ CÁCH KHÁCH'),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ),
                                ),
                                
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 50),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

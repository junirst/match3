import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager {
  static String _currentLanguage = 'English';
  static Map<String, Map<String, String>> _translations = {};

  static String get currentLanguage => _currentLanguage;

  static void setLanguage(String language) {
    _currentLanguage = language;
    _loadTranslations();
  }

  // Initialize language from SharedPreferences
  static Future<void> initializeLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'English';
    _loadTranslations();
  }

  // Save language preference
  static Future<void> saveLanguagePreference(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    _currentLanguage = language;
    _loadTranslations();
  }

  // Load all translations
  static void _loadTranslations() {
    _translations = {
      'English': _englishTranslations,
      'Vietnamese': _vietnameseTranslations,
    };
  }

  // Get translated text by key
  static String getText(String key) {
    _loadTranslations();
    return _translations[_currentLanguage]?[key] ?? key;
  }

  // Helper method for backward compatibility
  static String getLocalizedText(String englishText, String vietnameseText) {
    return _currentLanguage == 'Vietnamese' ? vietnameseText : englishText;
  }

  // English translations
  static final Map<String, String> _englishTranslations = {
    // Common
    'back': 'BACK',
    'play': 'PLAY',
    'level': 'LEVEL',
    'chapter': 'CHAPTER',
    'season': 'SEASON',
    'yes': 'Yes',
    'no': 'No',
    'cancel': 'Cancel',
    'confirm': 'CONFIRM',
    'ok': 'OK',

    // Main Menu
    'story_mode': 'STORY MODE',
    'tower_mode': 'TOWER MODE',
    'shop': 'SHOP',
    'settings': 'SETTINGS',
    'leaderboard': 'LEADERBOARD',

    // Chapters
    'chapter_1': 'CHAPTER 1',
    'chapter_2': 'CHAPTER 2',
    'chapter_not_implemented': 'Chapter 2 functionality not implemented yet',

    // Levels
    'level_1_1': 'Level 1.1',
    'level_1_2': 'Level 1.2',
    'level_1_3': 'Level 1.3',
    'level_1_4': 'Level 1.4',
    'level_1_5': 'Level 1.5',
    'reward': 'Reward:',

    // Shop & Upgrades
    'outfit': 'OUTFIT',
    'weapons': 'WEAPONS',
    'upgrade': 'UPGRADE',
    'upgrades': 'UPGRADES',
    'buy': 'BUY',
    'purchase_not_implemented': 'Purchase functionality not implemented yet',

    // Purchase System
    'confirmPurchase': 'Confirm Purchase',
    'purchaseFor': 'Purchase for',
    'coins': 'coins',
    'refuse': 'REFUSE',
    'notEnoughCoins': 'Not enough coins!',
    'purchaseSuccess': 'Upgrade successful!',
    'maxLevel': 'Max level reached!',

    // Leaderboard
    'leaderboard_title': 'LEADERBOARD',
    'resets_in': 'RESETS IN:',
    'days': 'DAYS',
    'day': 'DAY',
    'hours': 'HOURS',
    'hour': 'HOUR',
    'minutes': 'M',

    // Settings & Language
    'language': 'LANGUAGE',
    'english': 'ENGLISH',
    'vietnamese': 'TIẾNG VIỆT',
    'change_language': 'Change Language',
    'change_language_confirm': 'Are you sure you want to change the language to English?',
    'change_language_confirm_vn': 'Are you sure you want to change the language to Vietnamese?',

    // Tower Mode
    'tower_mode_title': 'TOWER MODE',
    'floor': 'FLOOR',
    'floors': 'FLOORS',
    'climb_tower': 'CLIMB THE TOWER',

    // Game UI
    'score': 'Score',
    'time': 'Time',
    'moves': 'Moves',
    'objectives': 'Objectives',

    // Notifications
    'coming_soon': 'Coming Soon!',
    'feature_not_available': 'This feature is not available yet',
    'game_saved': 'Game Saved',
    'game_loaded': 'Game Loaded',

    // Upgrade Types
    'sword_upgrade': 'Sword Damage',
    'heart_upgrade': 'Health Points',
    'star_upgrade': 'Special Power',
    'shield_upgrade': 'Defense',

    // Gameplay Screen
    'defeat': 'DEFEAT!',
    'victory': 'VICTORY!',
    'retry': 'RETRY',
    'continue': 'CONTINUE',
    'game_paused': 'GAME PAUSED',
    'what_would_you_like_to_do': 'What would you like to do?',
    'resume': 'RESUME',
    'quit': 'QUIT',
    'health': 'HEALTH',
    'power': 'POWER',
  };

  // Vietnamese translations
  static final Map<String, String> _vietnameseTranslations = {
    // Common
    'back': 'QUAY LẠI',
    'play': 'CHƠI',
    'level': 'CẤP',
    'chapter': 'CHƯƠNG',
    'season': 'MÙA',
    'yes': 'Có',
    'no': 'Không',
    'cancel': 'Hủy',
    'confirm': 'XÁC NHẬN',
    'ok': 'Đồng ý',

    // Main Menu
    'story_mode': 'CHẾ ĐỘ TRUYỆN',
    'tower_mode': 'CHẾ ĐỘ THÁP',
    'shop': 'CỬA HÀNG',
    'settings': 'CÀI ĐẶT',
    'leaderboard': 'BẢNG XẾP HẠNG',

    // Chapters
    'chapter_1': 'CHƯƠNG 1',
    'chapter_2': 'CHƯƠNG 2',
    'chapter_not_implemented': 'Chức năng Chương 2 chưa được triển khai',

    // Levels
    'level_1_1': 'Cấp 1.1',
    'level_1_2': 'Cấp 1.2',
    'level_1_3': 'Cấp 1.3',
    'level_1_4': 'Cấp 1.4',
    'level_1_5': 'Cấp 1.5',
    'reward': 'Phần thưởng:',

    // Shop & Upgrades
    'outfit': 'TRANG PHỤC',
    'weapons': 'VŨ KHÍ',
    'upgrade': 'NÂNG CẤP',
    'upgrades': 'NÂNG CẤP',
    'buy': 'MUA',
    'purchase_not_implemented': 'Chức năng mua hàng chưa được triển khai',

    // Purchase System
    'confirmPurchase': 'Xác Nhận Nâng Cấp',
    'purchaseFor': 'Nâng cấp với giá',
    'coins': 'xu',
    'refuse': 'TỪ CHỐI',
    'notEnoughCoins': 'Không đủ xu!',
    'purchaseSuccess': 'Nâng cấp thành công!',
    'maxLevel': 'Đã đạt cấp độ tối đa!',

    // Leaderboard
    'leaderboard_title': 'BẢNG XẾP HẠNG',
    'resets_in': 'RESET TRONG:',
    'days': 'NGÀY',
    'day': 'NGÀY',
    'hours': 'GIỜ',
    'hour': 'GIỜ',
    'minutes': 'PHÚT',

    // Settings & Language
    'language': 'NGÔN NGỮ',
    'english': 'TIẾNG ANH',
    'vietnamese': 'TIẾNG VIỆT',
    'change_language': 'Thay Đổi Ngôn Ngữ',
    'change_language_confirm': 'Bạn có chắc chắn muốn thay đổi ngôn ngữ sang Tiếng Anh?',
    'change_language_confirm_vn': 'Bạn có chắc chắn muốn thay đổi ngôn ngữ sang Tiếng Việt?',

    // Tower Mode
    'tower_mode_title': 'CHẾ ĐỘ THÁP',
    'floor': 'TẦNG',
    'floors': 'TẦNG',
    'climb_tower': 'LEO THÁP',

    // Game UI
    'score': 'Điểm',
    'time': 'Thời gian',
    'moves': 'Nước đi',
    'objectives': 'Mục tiêu',

    // Notifications
    'coming_soon': 'Sắp Ra Mắt!',
    'feature_not_available': 'Tính năng này chưa có sẵn',
    'game_saved': 'Đã Lưu Trò Chơi',
    'game_loaded': 'Đã Tải Trò Chơi',

    // Upgrade Types
    'sword_upgrade': 'Sát Thương Kiếm',
    'heart_upgrade': 'Điểm Sức Khỏe',
    'star_upgrade': 'Sức Mạnh Đặc Biệt',
    'shield_upgrade': 'Phòng Thủ',

    // Gameplay Screen
    'defeat': 'THẤT BẠI!',
    'victory': 'CHIẾN THẮNG!',
    'retry': 'THỬ LẠI',
    'continue': 'TIẾP TỤC',
    'game_paused': 'TẠM DỪNG GAME',
    'what_would_you_like_to_do': 'Bạn muốn làm gì?',
    'resume': 'TIẾP TỤC',
    'quit': 'THOÁT',
    'health': 'SỨC KHỎE',
    'power': 'SỨC MẠNH',
  };
}

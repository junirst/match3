class LanguageManager {
  static String _currentLanguage = 'English';

  static String get currentLanguage => _currentLanguage;

  static void setLanguage(String language) {
    _currentLanguage = language;
  }
}
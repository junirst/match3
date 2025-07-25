class LanguageManager {
  static String _currentLanguage = 'English'; // Changed from Vietnamese to English

  static String get currentLanguage => _currentLanguage;

  static void setLanguage(String language) {
    _currentLanguage = language;
  }

  // Helper method to get localized text
  static String getLocalizedText(String englishText, String vietnameseText) {
    return _currentLanguage == 'Vietnamese' ? vietnameseText : englishText;
  }
}
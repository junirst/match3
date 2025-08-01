/// Debug logging utility for the Match3 game
///
/// This utility provides centralized logging with different levels
/// and can be easily disabled for production builds.
class DebugLogger {
  static const bool _debugMode = true; // Set to false for production

  /// Log general information
  static void info(String message) {
    if (_debugMode) {
      print('[INFO] $message');
    }
  }

  /// Log game state changes
  static void gameState(String message) {
    if (_debugMode) {
      print('[GAME] $message');
    }
  }

  /// Log match and combo information
  static void match(String message) {
    if (_debugMode) {
      print('[MATCH] $message');
    }
  }

  /// Log enemy and damage information
  static void combat(String message) {
    if (_debugMode) {
      print('[COMBAT] $message');
    }
  }

  /// Log error messages
  static void error(String message, [Object? error]) {
    if (_debugMode) {
      print('[ERROR] $message${error != null ? ': $error' : ''}');
    }
  }

  /// Log sprite loading information
  static void sprite(String message) {
    if (_debugMode) {
      print('[SPRITE] $message');
    }
  }
}

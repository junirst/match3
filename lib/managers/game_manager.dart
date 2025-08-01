import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/game_models.dart';

class GameManager extends ChangeNotifier {
  Player? _currentPlayer;
  List<Chapter> _chapters = [];
  List<PlayerProgress> _playerProgress = [];
  List<LeaderboardEntry> _leaderboard = [];
  PlayerStats? _playerStats;
  GameSession? _currentGameSession;
  bool _isLoading = false;
  String? _error;

  // Getters
  Player? get currentPlayer => _currentPlayer;
  List<Chapter> get chapters => _chapters;
  List<PlayerProgress> get playerProgress => _playerProgress;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  PlayerStats? get playerStats => _playerStats;
  GameSession? get currentGameSession => _currentGameSession;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize game manager
  Future<void> initialize() async {
    await _loadPlayerFromStorage();
    if (_currentPlayer != null) {
      await loadPlayerData();
    }
    // Remove any hard-coded coin values from SharedPreferences
    await _cleanupLegacyCoinStorage();
  }

  // Authentication methods
  Future<bool> loginPlayer(String email, String password) async {
    _setLoading(true);
    try {
      final response = await ApiService.loginPlayer(email, password);
      if (response != null) {
        if (response.containsKey('error')) {
          _setError(response['error']);
          return false;
        } else if (response['player'] != null) { // Fixed: 'player' instead of 'Player'
          _currentPlayer = Player.fromJson(response['player']);
          await _savePlayerToStorage();
          await loadPlayerData();
          _setError(null);
          notifyListeners();
          return true;
        }
      }
      _setError('Login failed');
      return false;
    } catch (e) {
      _setError('Login error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerPlayer({
    required String playerName,
    required String password,
    String? email,
    String? gender,
    String? languagePreference,
  }) async {
    _setLoading(true);
    try {
      final response = await ApiService.registerPlayer(
        playerName: playerName,
        password: password,
        email: email,
        gender: gender,
        languagePreference: languagePreference,
      );

      if (response != null) {
        if (response.containsKey('error')) {
          _setError(response['error']);
          return false;
        } else if (response['player'] != null) { // Fixed: 'player' instead of 'Player'
          _currentPlayer = Player.fromJson(response['player']);
          await _savePlayerToStorage();
          await loadPlayerData();
          _setError(null);
          notifyListeners();
          return true;
        }
      }
      _setError('Registration failed');
      return false;
    } catch (e) {
      _setError('Registration error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _currentPlayer = null;
    _chapters = [];
    _playerProgress = [];
    _leaderboard = [];
    _playerStats = null;
    _currentGameSession = null;
    _upgradeLevels = {}; // Clear upgrades data
    _error = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('player_id');
    await _cleanupLegacyCoinStorage();
    notifyListeners();
  }

  // Guest mode functionality
  void enableGuestMode() {
    _currentPlayer = null;
    _chapters = [];
    _playerProgress = [];
    _leaderboard = [];
    _playerStats = null;
    _currentGameSession = null;
    _upgradeLevels = {
      'sword': 1,
      'heart': 1,
      'star': 1,
      'shield': 1,
    }; // Default upgrades for guest
    _error = null;
    notifyListeners();
  }

  bool get isGuestMode => _currentPlayer == null;

  // Player data methods
  Future<void> loadPlayerData() async {
    if (_currentPlayer == null) return;

    await Future.wait([
      loadPlayerUpgrades(),
      loadChapters(),
      loadPlayerProgress(),
      loadPlayerStats(),
      loadLeaderboard(),
    ]);
  }

  Future<void> loadChapters() async {
    try {
      final response = await ApiService.getChapters();
      if (response != null) {
        _chapters = response.map((json) => Chapter.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading chapters: $e');
    }
  }

  Future<void> loadPlayerProgress() async {
    if (_currentPlayer == null) return;

    try {
      final response = await ApiService.getPlayerProgress(
        _currentPlayer!.playerId,
      );
      if (response != null) {
        _playerProgress = response
            .map((json) => PlayerProgress.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading player progress: $e');
    }
  }

  Future<void> loadPlayerStats() async {
    if (_currentPlayer == null) return;

    try {
      final response = await ApiService.getPlayerStats(
        _currentPlayer!.playerId,
      );
      if (response != null) {
        _playerStats = PlayerStats.fromJson(response);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading player stats: $e');
    }
  }

  Future<void> loadLeaderboard() async {
    try {
      final response = await ApiService.getLeaderboard();
      if (response != null) {
        _leaderboard = response
            .map((json) => LeaderboardEntry.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading leaderboard: $e');
    }
  }

  // Game session methods
  Future<bool> startGameSession({
    String gameMode = 'Chapter',
    int? chapterId,
    int? levelNumber,
    int? towerFloor,
  }) async {
    if (_currentPlayer == null) return false;

    try {
      final response = await ApiService.startGameSession(
        playerId: _currentPlayer!.playerId,
        gameMode: gameMode,
        chapterId: chapterId,
        levelNumber: levelNumber,
        towerFloor: towerFloor,
      );

      if (response != null) {
        _currentGameSession = GameSession.fromJson(response);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error starting game session: $e');
      return false;
    }
  }

  Future<bool> completeGameSession({
    int? finalScore,
    bool enemyDefeated = false,
    int coinsEarned = 0,
  }) async {
    if (_currentGameSession == null) return false;

    try {
      final success = await ApiService.completeGameSession(
        sessionId: _currentGameSession!.sessionId,
        finalScore: finalScore,
        enemyDefeated: enemyDefeated,
        coinsEarned: coinsEarned,
      );

      if (success) {
        // Update player coins locally
        if (coinsEarned > 0 && _currentPlayer != null) {
          _currentPlayer = _currentPlayer!.copyWith(
            coins: (_currentPlayer!.coins ?? 0) + coinsEarned,
          );
        }

        _currentGameSession = null;
        notifyListeners();

        // Reload player data to get updated stats
        await loadPlayerData();
        return true;
      }
      return false;
    } catch (e) {
      print('Error completing game session: $e');
      return false;
    }
  }

  Future<bool> completeLevel({
    required int chapterId,
    required int levelId,
    required int score,
    int coinsEarned = 0,
  }) async {
    if (_currentPlayer == null) return false;

    try {
      final success = await ApiService.completeLevel(
        playerId: _currentPlayer!.playerId,
        chapterId: chapterId,
        levelId: levelId,
        score: score,
        coinsEarned: coinsEarned,
      );

      if (success) {
        // Update player coins locally
        if (coinsEarned > 0) {
          _currentPlayer = _currentPlayer!.copyWith(
            coins: (_currentPlayer!.coins ?? 0) + coinsEarned,
          );
        }

        notifyListeners();

        // Reload progress and stats
        await Future.wait([loadPlayerProgress(), loadPlayerStats()]);

        return true;
      }
      return false;
    } catch (e) {
      print('Error completing level: $e');
      return false;
    }
  }

  // Player profile methods
  Future<bool> updatePlayerProfile({
    String? playerName,
    String? gender,
    String? languagePreference,
  }) async {
    if (_currentPlayer == null) return false;

    try {
      final success = await ApiService.updatePlayerProfile(
        playerId: _currentPlayer!.playerId,
        playerName: playerName,
        gender: gender,
        languagePreference: languagePreference,
      );

      if (success) {
        _currentPlayer = _currentPlayer!.copyWith(
          playerName: playerName ?? _currentPlayer!.playerName,
          gender: gender ?? _currentPlayer!.gender,
          languagePreference:
              languagePreference ?? _currentPlayer!.languagePreference,
        );

        await _savePlayerToStorage();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating player profile: $e');
      return false;
    }
  }

  Future<bool> updateCoins(int coinsChange) async {
    if (_currentPlayer == null) return false;

    try {
      final response = await ApiService.updateCoins(
        playerId: _currentPlayer!.playerId,
        coinsChange: coinsChange,
      );

      if (response != null && response['newCoinsAmount'] != null) {
        _currentPlayer = _currentPlayer!.copyWith(
          coins: response['newCoinsAmount'],
        );

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating coins: $e');
      return false;
    }
  }

  // Utility methods
  bool isLevelCompleted(int chapterId, int levelId) {
    return _playerProgress.any(
      (progress) =>
          progress.chapterId == chapterId &&
          progress.levelId == levelId &&
          progress.isCompleted,
    );
  }

  int? getLevelBestScore(int chapterId, int levelId) {
    final progress = _playerProgress.firstWhere(
      (progress) =>
          progress.chapterId == chapterId && progress.levelId == levelId,
      orElse: () =>
          PlayerProgress(progressId: 0, playerId: '', isCompleted: false),
    );
    return progress.bestScore;
  }

  // Coin management methods
  int get currentCoins => _currentPlayer?.coins ?? 0;

  Future<bool> spendCoins(int amount, String reason) async {
    if (_currentPlayer == null) return false;
    
    final currentCoins = _currentPlayer!.coins ?? 0;
    if (currentCoins < amount) {
      _setError('Not enough coins! You need $amount coins but only have $currentCoins.');
      return false;
    }

    try {
      // Calculate coins change (negative for spending)
      final coinsChange = -amount;
      final response = await ApiService.updateCoins(
        playerId: _currentPlayer!.playerId, 
        coinsChange: coinsChange
      );
      
      if (response != null && response['success'] == true) {
        _currentPlayer!.coins = currentCoins - amount;
        await _savePlayerToStorage();
        notifyListeners();
        return true;
      } else {
        _setError('Failed to update coins on server');
        return false;
      }
    } catch (e) {
      _setError('Error updating coins: $e');
      return false;
    }
  }

  Future<bool> addCoins(int amount, String reason) async {
    if (_currentPlayer == null) return false;

    try {
      final currentCoins = _currentPlayer!.coins ?? 0;
      // Calculate coins change (positive for adding)
      final coinsChange = amount;
      final response = await ApiService.updateCoins(
        playerId: _currentPlayer!.playerId, 
        coinsChange: coinsChange
      );
      
      if (response != null && response['success'] == true) {
        _currentPlayer!.coins = currentCoins + amount;
        await _savePlayerToStorage();
        notifyListeners();
        return true;
      } else {
        _setError('Failed to update coins on server');
        return false;
      }
    } catch (e) {
      _setError('Error updating coins: $e');
      return false;
    }
  }

  // Upgrade management methods
  Map<String, int> _upgradeLevels = {};
  
  Map<String, int> get upgradeLevels => _upgradeLevels;

  Future<void> loadPlayerUpgrades() async {
    if (_currentPlayer == null) return;

    try {
      final response = await ApiService.getPlayerUpgrades(_currentPlayer!.playerId);
      if (response != null) {
        _upgradeLevels = Map<String, int>.from(response.map((key, value) => MapEntry(key, value as int)));
        
        // Ensure all upgrade types have at least level 1
        final defaultUpgrades = ['sword', 'heart', 'star', 'shield'];
        for (String upgradeType in defaultUpgrades) {
          if (!_upgradeLevels.containsKey(upgradeType)) {
            _upgradeLevels[upgradeType] = 1;
          }
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Error loading upgrades: $e');
    }
  }

  Future<bool> updateUpgradeLevel(String upgradeType, int newLevel) async {
    if (_currentPlayer == null) return false;

    try {
      final response = await ApiService.updatePlayerUpgrade(
        playerId: _currentPlayer!.playerId,
        upgradeType: upgradeType,
        level: newLevel,
      );
      
      if (response != null && response['success'] == true) {
        _upgradeLevels[upgradeType] = newLevel;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to update upgrade on server');
        return false;
      }
    } catch (e) {
      _setError('Error updating upgrade: $e');
      return false;
    }
  }

  Future<bool> purchaseUpgrade(String upgradeType, int quantity, int totalCost) async {
    // First spend the coins
    final coinsSpent = await spendCoins(totalCost, 'Upgrade $upgradeType x$quantity');
    if (!coinsSpent) return false;

    // Then update the upgrade level
    final currentLevel = _upgradeLevels[upgradeType] ?? 1;
    final newLevel = currentLevel + quantity;
    
    final upgradeUpdated = await updateUpgradeLevel(upgradeType, newLevel);
    if (!upgradeUpdated) {
      // If upgrade update failed, try to refund coins
      await addCoins(totalCost, 'Refund for failed upgrade');
      return false;
    }

    return true;
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> _savePlayerToStorage() async {
    if (_currentPlayer != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('player_id', _currentPlayer!.playerId);
    }
  }

  Future<void> _loadPlayerFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final playerId = prefs.getString('player_id');

    if (playerId != null) {
      // Try to load player profile from API
      final response = await ApiService.getPlayerProfile(playerId);
      if (response != null) {
        _currentPlayer = Player.fromJson(response);
        notifyListeners();
      }
    }
  }

  Future<void> _cleanupLegacyCoinStorage() async {
    final prefs = await SharedPreferences.getInstance();
    // Remove the old hard-coded coins storage
    await prefs.remove('coins');
  }
}

// Singleton instance
final gameManager = GameManager();

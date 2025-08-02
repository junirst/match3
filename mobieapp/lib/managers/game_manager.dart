import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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

  // Guest mode data
  int _guestCoins = 100; // Starting coins for guest
  List<PlayerProgress> _guestProgress = []; // Guest progress storage
  Map<String, int> _guestUpgradeLevels = {}; // Guest upgrade levels
  String _guestEquippedWeapon = 'Hand'; // Guest equipped weapon
  List<String> _guestOwnedWeapons = ['Hand']; // Guest owned weapons

  // Season management
  int _currentSeason = 0;
  DateTime? _seasonEndTime;

  // Getters that support guest mode
  Player? get currentPlayer => _currentPlayer;
  List<Chapter> get chapters => _chapters;
  List<PlayerProgress> get playerProgress =>
      isGuestMode ? _guestProgress : _playerProgress;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  PlayerStats? get playerStats => _playerStats;
  GameSession? get currentGameSession => _currentGameSession;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Season getters
  int get currentSeason => _currentSeason;
  DateTime? get seasonEndTime => _seasonEndTime;

  // Initialize game manager
  Future<void> initialize() async {
    await _loadPlayerFromStorage();
    if (_currentPlayer != null) {
      await loadPlayerData();
    } else {
      // If no player is loaded, initialize guest mode data
      await _loadGuestModeData();
    }
    // Load season data
    await loadSeasonData();
    // Remove any hard-coded coin values from SharedPreferences
    await _cleanupLegacyCoinStorage();
  }

  // Authentication methods
  Future<bool> loginPlayer(String email, String password) async {
    print('Starting login for email: $email'); // Debug log
    _setLoading(true);
    try {
      final response = await ApiService.loginPlayer(email, password);
      print('Login response: $response'); // Debug log
      if (response != null) {
        if (response.containsKey('error')) {
          print('Login error from API: ${response['error']}'); // Debug log
          _setError(response['error']);
          _setLoading(false); // Clear loading immediately
          notifyListeners();
          return false;
        } else if (response['player'] != null) {
          print('Login successful, parsing player data'); // Debug log
          // Fixed: 'player' instead of 'Player'
          _currentPlayer = Player.fromJson(response['player']);
          print(
            'Player weapons loaded: ${_currentPlayer!.weapons?.length ?? 0}',
          );
          print('Owned weapons: ${ownedWeapons.join(", ")}');
          await _savePlayerToStorage();
          _setError(null);
          _setLoading(false); // Clear loading immediately
          notifyListeners();
          print(
            'Login completed, loading additional data in background',
          ); // Debug log

          // Load additional data in background without blocking UI
          loadPlayerData().catchError((e) {
            print('Error loading player data: $e');
          });

          // Ensure player is initialized in leaderboard (safe to call multiple times)
          initializePlayerInLeaderboard().catchError((e) {
            print('Error initializing player in leaderboard: $e');
          });

          return true;
        }
      }
      print('Login failed - no valid response'); // Debug log
      _setError('Login failed');
      _setLoading(false); // Clear loading immediately
      notifyListeners();
      return false;
    } catch (e) {
      print('Login exception: $e'); // Debug log
      _setError('Login error: $e');
      _setLoading(false); // Clear loading immediately
      notifyListeners();
      return false;
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
        print('Registration response: $response'); // Debug log
        if (response.containsKey('error')) {
          _setError(response['error']);
          _setLoading(false); // Clear loading state immediately
          notifyListeners();
          return false;
        } else if (response['player'] != null) {
          // API returns 'player' (lowercase p) in registration response
          print('Parsing player data from response'); // Debug log
          _currentPlayer = Player.fromJson(response['player']);

          try {
            await _savePlayerToStorage();
            print('Player data saved to storage'); // Debug log
          } catch (e) {
            print('Error saving player to storage: $e'); // Debug log
            // Continue anyway, user can login later
          }

          // Don't load all player data during registration - just save the basic info
          // loadPlayerData() will be called later during login

          // Initialize player in leaderboard
          await initializePlayerInLeaderboard();

          _setError(null);
          _setLoading(false); // Clear loading state immediately
          notifyListeners();
          print('Registration completed successfully'); // Debug log
          return true;
        } else if (response['message'] != null &&
            response['message'].contains('successful')) {
          // Registration was successful but no player data returned, that's ok
          _setError(null);
          _setLoading(false); // Clear loading state immediately
          notifyListeners();
          return true;
        }
      }
      print(
        'Registration failed - no player or success message found',
      ); // Debug log
      _setError('Registration failed');
      _setLoading(false); // Clear loading state immediately
      notifyListeners();
      return false;
    } catch (e) {
      print('Registration error: $e'); // Debug log
      _setError('Registration error: $e');
      _setLoading(false); // Clear loading state immediately
      notifyListeners();
      return false;
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

    // Clear guest mode data
    _guestCoins = 100;
    _guestProgress = [];

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('player_id');
    await _cleanupLegacyCoinStorage();
    // Clear guest data from storage
    await prefs.remove('guest_coins');
    await prefs.remove('guest_progress');
    notifyListeners();
  }

  // Guest mode functionality
  void enableGuestMode() async {
    _currentPlayer = null;
    _chapters = [];
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

    // Load guest mode progress and coins from local storage
    await _loadGuestModeData();

    notifyListeners();
  }

  bool get isGuestMode => _currentPlayer == null;

  // Guest mode data management
  Future<void> _loadGuestModeData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load guest coins
    _guestCoins = prefs.getInt('guest_coins') ?? 100;

    // Load guest progress from SharedPreferences
    final progressData = prefs.getStringList('guest_progress') ?? [];
    _guestProgress = progressData.map((jsonString) {
      final json = jsonDecode(jsonString);
      return PlayerProgress.fromJson(json);
    }).toList();

    // Load guest upgrade levels
    final upgradeData = prefs.getString('guest_upgrades');
    if (upgradeData != null) {
      final upgrades = jsonDecode(upgradeData) as Map<String, dynamic>;
      _guestUpgradeLevels = upgrades.map(
        (key, value) => MapEntry(key, value as int),
      );
    } else {
      _guestUpgradeLevels = {'sword': 1, 'heart': 1, 'star': 1, 'shield': 1};
    }

    // Load guest equipped weapon
    _guestEquippedWeapon = prefs.getString('guest_weapon') ?? 'Hand';

    // Load guest owned weapons
    final ownedWeaponsData = prefs.getStringList('guest_owned_weapons');
    if (ownedWeaponsData != null) {
      _guestOwnedWeapons = ownedWeaponsData;
    } else {
      _guestOwnedWeapons = ['Hand'];
    }

    print(
      'Loaded guest mode data: ${_guestCoins} coins, ${_guestProgress.length} progress entries, weapon: $_guestEquippedWeapon',
    );

    // Debug: Print each progress entry being loaded
    for (var progress in _guestProgress) {
      print(
        'Loaded progress: Chapter ${progress.chapterId}, Level ${progress.levelId}, Completed: ${progress.isCompleted}',
      );
    }

    // Debug: Print upgrade levels
    print('Guest upgrade levels: $_guestUpgradeLevels');
  }

  // Clear guest mode data (for testing)
  Future<void> clearGuestModeData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('guest_coins');
    await prefs.remove('guest_progress');
    await prefs.remove('guest_upgrades');
    await prefs.remove('guest_weapon');
    _guestCoins = 100;
    _guestProgress.clear();
    _guestUpgradeLevels = {'sword': 1, 'heart': 1, 'star': 1, 'shield': 1};
    _guestEquippedWeapon = 'Hand';
    _guestOwnedWeapons = ['Hand'];
    notifyListeners();
    print(
      'Guest mode data cleared. Reset to 100 coins, no progress, level 1 upgrades, and Hand weapon.',
    );
  }

  Future<void> _saveGuestModeData() async {
    if (!isGuestMode) return;

    final prefs = await SharedPreferences.getInstance();

    // Save guest coins
    await prefs.setInt('guest_coins', _guestCoins);

    // Save guest progress
    final progressData = _guestProgress
        .map((progress) => jsonEncode(progress.toJson()))
        .toList();
    await prefs.setStringList('guest_progress', progressData);

    // Save guest upgrade levels
    await prefs.setString('guest_upgrades', jsonEncode(_guestUpgradeLevels));

    // Save guest equipped weapon
    await prefs.setString('guest_weapon', _guestEquippedWeapon);

    // Save guest owned weapons
    await prefs.setStringList('guest_owned_weapons', _guestOwnedWeapons);

    print(
      'Saved guest mode data: ${_guestCoins} coins, ${_guestProgress.length} progress entries, weapon: $_guestEquippedWeapon',
    );

    // Debug: Print each progress entry being saved
    for (var progress in _guestProgress) {
      print(
        'Saving progress: Chapter ${progress.chapterId}, Level ${progress.levelId}, Completed: ${progress.isCompleted}',
      );
    }

    // Debug: Print upgrade levels
    print('Saved guest upgrade levels: $_guestUpgradeLevels');
  }

  // Player data methods
  Future<void> loadPlayerData() async {
    if (_currentPlayer == null) return;

    print('Loading player data for ${_currentPlayer!.playerName}'); // Debug log
    try {
      await Future.wait([
        refreshPlayerInfo(), // Add refresh player info including coins
        loadPlayerUpgrades(),
        loadChapters(),
        loadPlayerProgress(),
        loadPlayerStats(),
        loadLeaderboard(),
      ]).timeout(Duration(seconds: 30)); // Add timeout
      print('Player data loaded successfully'); // Debug log
    } catch (e) {
      print('Error loading player data: $e'); // Debug log
      // Don't throw error, just log it so UI is not affected
    }
  }

  // Add method to refresh player basic info including coins
  Future<void> refreshPlayerInfo() async {
    if (_currentPlayer == null) return;

    try {
      final response = await ApiService.getPlayerProfile(
        _currentPlayer!.playerId,
      );
      if (response != null) {
        // getPlayerProfile returns the profile object directly, not wrapped in 'player'
        _currentPlayer = Player.fromJson(response);
        await _savePlayerToStorage();
        print('Player info refreshed, current coins: ${_currentPlayer!.coins}');
        print('Player weapons count: ${_currentPlayer!.weapons?.length ?? 0}');
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing player info: $e');
    }
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
    // In guest mode, load from local storage
    if (isGuestMode) {
      await _loadGuestModeData();
      notifyListeners();
      return;
    }

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
    // Handle guest mode with local storage
    if (isGuestMode) {
      // Add coins for guest
      if (coinsEarned > 0) {
        _guestCoins += coinsEarned;
      }

      // Create or update guest progress
      final existingProgressIndex = _guestProgress.indexWhere(
        (p) => p.chapterId == chapterId && p.levelId == levelId,
      );

      if (existingProgressIndex >= 0) {
        // Update existing progress if score is better
        final existingProgress = _guestProgress[existingProgressIndex];
        if (score > (existingProgress.bestScore ?? 0)) {
          _guestProgress[existingProgressIndex] = PlayerProgress(
            progressId: existingProgress.progressId,
            playerId: 'guest',
            chapterId: chapterId,
            levelId: levelId,
            isCompleted: true,
            bestScore: score,
            completedDate: DateTime.now(),
          );
        }
      } else {
        // Create new progress entry
        _guestProgress.add(
          PlayerProgress(
            progressId: _guestProgress.length + 1,
            playerId: 'guest',
            chapterId: chapterId,
            levelId: levelId,
            isCompleted: true,
            bestScore: score,
            completedDate: DateTime.now(),
          ),
        );
      }

      // Save guest mode data
      await _saveGuestModeData();
      notifyListeners();

      print(
        'Guest completed Level $chapterId.$levelId - Coins: $_guestCoins (+$coinsEarned), Score: $score',
      );
      return true;
    }

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

        // Update leaderboard with new score if level 2+ is completed
        if (levelId >= 2) {
          await _updateLeaderboardProgress(score: score);
        }

        // Refresh player info to ensure accurate coin balance
        await refreshPlayerInfo();

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
    int? towerRecord,
  }) async {
    if (_currentPlayer == null) return false;

    try {
      final success = await ApiService.updatePlayerProfile(
        playerId: _currentPlayer!.playerId,
        playerName: playerName,
        gender: gender,
        languagePreference: languagePreference,
        towerRecord: towerRecord,
      );

      if (success) {
        _currentPlayer = _currentPlayer!.copyWith(
          playerName: playerName ?? _currentPlayer!.playerName,
          gender: gender ?? _currentPlayer!.gender,
          languagePreference:
              languagePreference ?? _currentPlayer!.languagePreference,
          towerRecord: towerRecord ?? _currentPlayer!.towerRecord,
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

  // Method to update tower record specifically
  Future<bool> updateTowerRecord(int newRecord) async {
    if (_currentPlayer == null) return false;

    // Only update if new record is higher than current
    final currentRecord = _currentPlayer!.towerRecord ?? 0;
    if (newRecord <= currentRecord) return true;

    final success = await updatePlayerProfile(towerRecord: newRecord);

    // Also update leaderboard with new tower level
    if (success) {
      await _updateLeaderboardProgress(towerLevel: newRecord);
    }

    return success;
  }

  // Method to update player progress (level completion)
  Future<bool> updatePlayerProgress({
    required String chapterId,
    required int levelNumber,
    bool? completed,
    int? towerFloor,
    int score = 0,
    int coinsEarned = 0,
  }) async {
    if (_currentPlayer == null) return false;

    try {
      if (completed == true) {
        // Use completeLevel API for level completion
        final success = await ApiService.completeLevel(
          playerId: _currentPlayer!.playerId,
          chapterId: int.tryParse(chapterId) ?? 1,
          levelId: levelNumber,
          score: score,
          coinsEarned: coinsEarned,
        );

        if (success) {
          // Reload player progress to get updated data
          await loadPlayerProgress();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error updating player progress: $e');
      return false;
    }
  }

  // Weapon management methods
  Future<bool> purchaseWeapon(String weaponName, int cost) async {
    // Handle guest mode weapon purchase
    if (isGuestMode) {
      // Check if weapon is already owned
      if (_guestOwnedWeapons.contains(weaponName)) {
        print('Guest already owns weapon: $weaponName');
        return true;
      }

      // Check if guest has enough coins
      if (_guestCoins < cost) {
        print('Not enough coins! Need $cost but have $_guestCoins');
        return false;
      }

      // Purchase weapon for guest
      _guestOwnedWeapons.add(weaponName);
      _guestCoins -= cost;

      // Save guest data
      await _saveGuestModeData();
      notifyListeners();

      print(
        'Guest purchased weapon: $weaponName for $cost coins. Remaining coins: $_guestCoins',
      );
      return true;
    }

    // Handle authenticated user weapon purchase
    if (_currentPlayer == null) return false;

    // Check if player has enough coins before making API call
    final currentCoins = _currentPlayer!.coins ?? 0;
    if (currentCoins < cost) {
      print('Not enough coins! Need $cost but have $currentCoins');
      return false;
    }

    try {
      final response = await ApiService.purchaseWeapon(
        playerId: _currentPlayer!.playerId,
        weaponName: weaponName,
        cost: cost,
      );

      if (response != null) {
        // Check if weapon was already owned
        if (response['alreadyOwned'] == true) {
          print('Weapon $weaponName was already owned');
          await refreshPlayerInfo(); // Refresh to get latest weapon status
          notifyListeners();
          return true;
        }

        // Update local player data including weapons
        _currentPlayer = _currentPlayer!.copyWith(
          coins: response['coins'] ?? _currentPlayer!.coins,
        );

        // Update weapons list from response
        if (response['weapons'] != null) {
          final weaponsList = (response['weapons'] as List)
              .map((json) => PlayerWeapon.fromJson(json))
              .toList();
          _currentPlayer = _currentPlayer!.copyWith(weapons: weaponsList);
          print('Updated weapons list: ${weaponsList.length} weapons');
        }

        // Refresh player profile to ensure data consistency
        await refreshPlayerInfo();
        await _savePlayerToStorage();
        notifyListeners();
        return true;
      } else {
        // Check if the error is "Weapon already owned" which means it's actually successful
        await refreshPlayerInfo(); // Refresh to get latest weapon status
        final isOwned = ownedWeapons.contains(weaponName);
        if (isOwned) {
          print('Weapon $weaponName is already owned, treating as success');
          notifyListeners();
          return true;
        }

        // Temporary fallback: Update local coins even if API fails
        // This is for testing UI while fixing server issue
        print('API failed, updating local coins as fallback');
        _currentPlayer = _currentPlayer!.copyWith(coins: currentCoins - cost);
        await _savePlayerToStorage();
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error purchasing weapon: $e');
      // Temporary fallback for testing
      print('Exception occurred, updating local coins as fallback');
      final currentCoins = _currentPlayer!.coins ?? 0;
      _currentPlayer = _currentPlayer!.copyWith(coins: currentCoins - cost);
      await _savePlayerToStorage();
      notifyListeners();
      return true;
    }
  }

  Future<bool> equipWeapon(String weaponName) async {
    // Handle guest mode weapon equipping
    if (isGuestMode) {
      // Check if weapon is owned by guest
      if (!_guestOwnedWeapons.contains(weaponName)) {
        print('Guest does not own weapon: $weaponName');
        return false;
      }

      // Equip weapon for guest
      _guestEquippedWeapon = weaponName;

      // Save guest data
      await _saveGuestModeData();
      notifyListeners();

      print('Guest equipped weapon: $weaponName');
      return true;
    }

    // Handle authenticated user weapon equipping
    if (_currentPlayer == null) return false;

    try {
      final success = await ApiService.equipWeapon(
        playerId: _currentPlayer!.playerId,
        weaponName: weaponName,
      );

      if (success) {
        _currentPlayer = _currentPlayer!.copyWith(equippedWeapon: weaponName);

        await _savePlayerToStorage();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error equipping weapon: $e');
      return false;
    }
  }

  // Get weapons owned by player
  List<String> get ownedWeapons {
    if (isGuestMode) {
      return _guestOwnedWeapons;
    }

    if (_currentPlayer?.weapons == null) return ['Sword']; // Default sword

    return _currentPlayer!.weapons!
        .where((weapon) => weapon.isOwned == true)
        .map((weapon) => weapon.weaponName)
        .toList();
  }

  String get equippedWeapon => isGuestMode
      ? _guestEquippedWeapon
      : (_currentPlayer?.equippedWeapon ?? 'Sword');

  // Player settings getters
  bool get bgmEnabled => _currentPlayer?.settings?.first.bgmEnabled ?? true;
  bool get sfxEnabled => _currentPlayer?.settings?.first.sfxEnabled ?? true;
  double get bgmVolume => _currentPlayer?.settings?.first.bgmVolume ?? 0.7;
  double get sfxVolume => _currentPlayer?.settings?.first.sfxVolume ?? 0.8;

  // Player stats getters
  int get totalGamesPlayed =>
      _currentPlayer?.stats?.first.totalGamesPlayed ?? 0;
  int get totalVictories => _currentPlayer?.stats?.first.totalVictories ?? 0;
  int get totalDefeats => _currentPlayer?.stats?.first.totalDefeats ?? 0;
  int get highestTowerFloor =>
      _currentPlayer?.stats?.first.highestTowerFloor ?? 0;

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
  int get currentCoins =>
      isGuestMode ? _guestCoins : (_currentPlayer?.coins ?? 0);

  Future<bool> spendCoins(int amount, String reason) async {
    if (_currentPlayer == null) return false;

    final currentCoins = _currentPlayer!.coins ?? 0;
    if (currentCoins < amount) {
      _setError(
        'Not enough coins! You need $amount coins but only have $currentCoins.',
      );
      return false;
    }

    try {
      // Calculate coins change (negative for spending)
      final coinsChange = -amount;
      final response = await ApiService.updateCoins(
        playerId: _currentPlayer!.playerId,
        coinsChange: coinsChange,
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
        coinsChange: coinsChange,
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

  Map<String, int> get upgradeLevels =>
      isGuestMode ? _guestUpgradeLevels : _upgradeLevels;

  Future<void> loadPlayerUpgrades() async {
    if (_currentPlayer == null) return;

    try {
      final response = await ApiService.getPlayerUpgrades(
        _currentPlayer!.playerId,
      );
      if (response != null) {
        _upgradeLevels = Map<String, int>.from(
          response.map((key, value) => MapEntry(key, value as int)),
        );

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

  Future<bool> purchaseUpgrade(
    String upgradeType,
    int quantity,
    int totalCost,
  ) async {
    // Handle guest mode upgrades
    if (isGuestMode) {
      // Check if guest has enough coins
      if (_guestCoins < totalCost) {
        _setError('Not enough coins! Need $totalCost but have $_guestCoins');
        return false;
      }

      // Calculate new level
      final currentLevel = _guestUpgradeLevels[upgradeType] ?? 1;
      final newLevel = currentLevel + quantity;

      // Update guest upgrade levels and coins
      _guestUpgradeLevels[upgradeType] = newLevel;
      _guestCoins -= totalCost;

      // Save guest data
      await _saveGuestModeData();
      notifyListeners();

      print(
        'Guest purchased $upgradeType upgrade: Level $currentLevel -> $newLevel, Cost: $totalCost, Remaining coins: $_guestCoins',
      );
      return true;
    }

    // Handle authenticated user upgrades
    if (_currentPlayer == null) return false;

    // Check if player has enough coins
    final currentCoins = _currentPlayer!.coins ?? 0;
    if (currentCoins < totalCost) {
      _setError('Not enough coins! Need $totalCost but have $currentCoins');
      return false;
    }

    // Calculate new level
    final currentLevel = _upgradeLevels[upgradeType] ?? 1;
    final newLevel = currentLevel + quantity;

    try {
      final response = await ApiService.purchasePlayerUpgrade(
        playerId: _currentPlayer!.playerId,
        upgradeType: upgradeType,
        newLevel: newLevel,
        totalCost: totalCost,
      );

      if (response != null && response['success'] == true) {
        // Update local data
        _upgradeLevels[upgradeType] = newLevel;
        _currentPlayer = _currentPlayer!.copyWith(
          coins: response['remainingCoins'] ?? (currentCoins - totalCost),
        );

        await _savePlayerToStorage();
        notifyListeners();
        return true;
      } else {
        _setError('Failed to purchase upgrade on server');
        return false;
      }
    } catch (e) {
      _setError('Error purchasing upgrade: $e');
      return false;
    }
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

  // Season management methods
  Future<void> loadSeasonData() async {
    try {
      // Load current season from API
      final response = await ApiService.getCurrentSeason();
      if (response != null) {
        _currentSeason = response['seasonNumber'] ?? 0;
        final endDateString = response['endDate'];
        if (endDateString != null) {
          _seasonEndTime = DateTime.parse(endDateString);
        }
        print(
          'Loaded season from API: Season ${_currentSeason}, ends at: ${_seasonEndTime}',
        );
        notifyListeners();
        return;
      }
    } catch (e) {
      print('Error loading season from API: $e');
    }

    // Fallback to SharedPreferences if API fails
    final prefs = await SharedPreferences.getInstance();

    int storedSeason = prefs.getInt('current_season') ?? 0;
    String? storedEndTimeString = prefs.getString('season_end_time');

    if (storedEndTimeString != null) {
      DateTime storedEndTime = DateTime.parse(storedEndTimeString);

      if (DateTime.now().isAfter(storedEndTime)) {
        // Season has ended, start new season
        storedSeason++;
        DateTime seasonEndTime = DateTime.now().add(Duration(days: 30));

        await prefs.setInt('current_season', storedSeason);
        await prefs.setString(
          'season_end_time',
          seasonEndTime.toIso8601String(),
        );

        _currentSeason = storedSeason;
        _seasonEndTime = seasonEndTime;
      } else {
        _currentSeason = storedSeason;
        _seasonEndTime = storedEndTime;
      }
    } else {
      // First time, initialize season
      DateTime seasonEndTime = DateTime.now().add(Duration(days: 30));
      await prefs.setInt('current_season', storedSeason);
      await prefs.setString('season_end_time', seasonEndTime.toIso8601String());

      _currentSeason = storedSeason;
      _seasonEndTime = seasonEndTime;
    }

    print(
      'Loaded season from SharedPreferences fallback: Season ${_currentSeason}',
    );
    notifyListeners();
  }

  String getCountdownText() {
    if (_seasonEndTime == null) return '';

    Duration remaining = _seasonEndTime!.difference(DateTime.now());
    if (remaining.isNegative) return 'Season Ended';

    int days = remaining.inDays;
    int hours = remaining.inHours % 24;
    int minutes = remaining.inMinutes % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
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

  // Helper method to update leaderboard progress
  Future<void> _updateLeaderboardProgress({int? score, int? towerLevel}) async {
    if (_currentPlayer == null) return;

    try {
      await ApiService.updatePlayerProgress(
        playerId: _currentPlayer!.playerId,
        score: score,
        towerLevel: towerLevel,
      );
      print(
        'Leaderboard updated successfully - Score: $score, Tower Level: $towerLevel',
      );
    } catch (e) {
      print('Error updating leaderboard progress: $e');
    }
  }

  // Method to initialize new player in leaderboard
  Future<void> initializePlayerInLeaderboard() async {
    if (_currentPlayer == null) return;

    try {
      await ApiService.initializeNewPlayer(playerId: _currentPlayer!.playerId);
      print('Player initialized in leaderboard successfully');
    } catch (e) {
      print('Error initializing player in leaderboard: $e');
    }
  }
}

// Singleton instance
final gameManager = GameManager();

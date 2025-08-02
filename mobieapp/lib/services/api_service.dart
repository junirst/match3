import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Environment configurations
  static const String _localEmulatorUrl =
      'http://10.0.2.2:5000/api'; // For Android emulator with local Docker
  static const String _localPhysicalUrl =
      'http://192.168.1.9:5000/api'; // Your local network IP
  static const String _remoteUrl =
      'http://1.54.215.45:5000/api'; // Your public IP for remote access

  // Current environment - change this based on your setup
  static String _currentEnv =
      'local_physical'; // Options: 'local_emulator', 'local_physical', 'remote'

  static void setEnvironment(String environment) {
    _currentEnv = environment;
    print('API Environment changed to: $environment');
    print('API Base URL is now: $baseUrl');
  }

  static String get baseUrl {
    switch (_currentEnv) {
      case 'local_emulator':
        return _localEmulatorUrl;
      case 'local_physical':
        return _localPhysicalUrl;
      case 'remote':
        return _remoteUrl;
      default:
        return _localEmulatorUrl;
    }
  }

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Player API methods
  static Future<Map<String, dynamic>?> getPlayerProfile(String playerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Player/$playerId/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error getting player profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting player profile: $e');
      return null;
    }
  }

  // Season API methods
  static Future<Map<String, dynamic>?> getCurrentSeason() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Player/current-season'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error getting current season: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting current season: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> loginPlayer(
    String email,
    String password,
  ) async {
    try {
      print('API Login - URL: $baseUrl/Player/login');
      print(
        'API Login - Request body: ${json.encode({'email': email, 'password': password})}',
      );

      final response = await http.post(
        Uri.parse('$baseUrl/Player/login'),
        headers: headers,
        body: json.encode({'email': email, 'password': password}),
      );

      print('API Login - Response status: ${response.statusCode}');
      print('API Login - Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        print('Invalid credentials');
        return {'error': 'Invalid Email or Password'};
      } else {
        print('Error logging in player: ${response.statusCode}');
        return {'error': 'Login failed'};
      }
    } catch (e) {
      print('Error logging in player: $e');
      return {'error': 'Connection error'};
    }
  }

  static Future<Map<String, dynamic>?> registerPlayer({
    required String playerName,
    required String password,
    String? email,
    String? gender,
    String? languagePreference,
  }) async {
    try {
      print('API Register - URL: $baseUrl/Player/register');
      print(
        'API Register - Request body: ${json.encode({'playerName': playerName, 'password': password, 'email': email, 'gender': gender, 'languagePreference': languagePreference})}',
      );

      final response = await http.post(
        Uri.parse('$baseUrl/Player/register'),
        headers: headers,
        body: json.encode({
          'playerName': playerName,
          'password': password,
          'email': email,
          'gender': gender,
          'languagePreference': languagePreference,
        }),
      );

      print('API Register - Response status: ${response.statusCode}');
      print('API Register - Response body: ${response.body}');

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 409) {
        final errorBody = json.decode(response.body);
        print('Registration conflict: $errorBody');
        return {'error': errorBody.toString()};
      } else {
        print('Error registering player: ${response.statusCode}');
        return {'error': 'Registration failed'};
      }
    } catch (e) {
      print('Error registering player: $e');
      return {'error': 'Connection error'};
    }
  }

  static Future<bool> updatePlayerProfile({
    required String playerId,
    String? playerName,
    String? gender,
    String? languagePreference,
    int? towerRecord,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (playerName != null) body['playerName'] = playerName;
      if (gender != null) body['gender'] = gender;
      if (languagePreference != null)
        body['languagePreference'] = languagePreference;
      if (towerRecord != null) body['towerRecord'] = towerRecord;

      final response = await http.put(
        Uri.parse('$baseUrl/Player/$playerId/updateProfile'),
        headers: headers,
        body: json.encode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating player profile: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> updateCoins({
    required String playerId,
    required int coinsChange,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Player/$playerId/updateCoins'),
        headers: headers,
        body: json.encode({'coinsChange': coinsChange}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error updating coins: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error updating coins: $e');
      return null;
    }
  }

  // Upgrade API methods
  static Future<Map<String, dynamic>?> getPlayerUpgrades(
    String playerId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Player/$playerId/upgrades'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error getting player upgrades: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting player upgrades: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updatePlayerUpgrade({
    required String playerId,
    required String upgradeType,
    required int level,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Player/$playerId/upgrades'),
        headers: headers,
        body: json.encode({'upgradeType': upgradeType, 'level': level}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error updating player upgrade: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error updating player upgrade: $e');
      return null;
    }
  }

  // Game Session API methods
  static Future<Map<String, dynamic>?> startGameSession({
    required String playerId,
    String gameMode = 'Chapter',
    int? chapterId,
    int? levelNumber,
    int? towerFloor,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/GameSession/start'),
        headers: headers,
        body: json.encode({
          'playerId': playerId,
          'gameMode': gameMode,
          'chapterId': chapterId,
          'levelNumber': levelNumber,
          'towerFloor': towerFloor,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        print('Error starting game session: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error starting game session: $e');
      return null;
    }
  }

  static Future<bool> completeGameSession({
    required int sessionId,
    int? finalScore,
    bool enemyDefeated = false,
    int coinsEarned = 0,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/GameSession/$sessionId/complete'),
        headers: headers,
        body: json.encode({
          'finalScore': finalScore,
          'enemyDefeated': enemyDefeated,
          'coinsEarned': coinsEarned,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error completing game session: $e');
      return false;
    }
  }

  static Future<List<dynamic>?> getPlayerGameSessions(String playerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/GameSession/player/$playerId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        print('Error getting player game sessions: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting player game sessions: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getPlayerStats(String playerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/GameSession/player/$playerId/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error getting player stats: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting player stats: $e');
      return null;
    }
  }

  // Chapter and Level API methods
  static Future<List<dynamic>?> getChapters() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Chapter'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        print('Error getting chapters: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting chapters: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getChapter(int chapterId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Chapter/$chapterId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error getting chapter: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting chapter: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> getPlayerProgress(String playerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/PlayerProgress/player/$playerId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        print('Error getting player progress: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting player progress: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getPlayerProgressSummary(
    String playerId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/PlayerProgress/player/$playerId/summary'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error getting player progress summary: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting player progress summary: $e');
      return null;
    }
  }

  static Future<bool> completeLevel({
    required String playerId,
    required int chapterId,
    required int levelId,
    required int score,
    int coinsEarned = 0,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/PlayerProgress/complete'),
        headers: headers,
        body: json.encode({
          'playerId': playerId,
          'chapterId': chapterId,
          'levelId': levelId,
          'score': score,
          'coinsEarned': coinsEarned,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error completing level: $e');
      return false;
    }
  }

  // Leaderboard API methods
  static Future<List<dynamic>?> getLeaderboard({int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Leaderboard?limit=$limit'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        print('Error getting leaderboard: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting leaderboard: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> getTowerLeaderboard({int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Leaderboard/tower?limit=$limit'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        print('Error getting tower leaderboard: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting tower leaderboard: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> getPlayerRanking(String playerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Leaderboard/player/$playerId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        print('Error getting player ranking: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting player ranking: $e');
      return null;
    }
  }

  // Weapon management methods
  static Future<Map<String, dynamic>?> purchaseWeapon({
    required String playerId,
    required String weaponName,
    required int cost,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Player/$playerId/purchaseWeapon'),
        headers: headers,
        body: json.encode({'weaponName': weaponName, 'cost': cost}),
      );

      print('Purchase weapon API response status: ${response.statusCode}');
      print('Purchase weapon API response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 400 &&
          response.body.contains('already owned')) {
        // Weapon already owned - treat as success but return special flag
        print('Weapon already owned, treating as success');
        return {'alreadyOwned': true};
      } else {
        print('Error purchasing weapon: ${response.statusCode}');
        print('Error response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error purchasing weapon: $e');
      return null;
    }
  }

  static Future<bool> equipWeapon({
    required String playerId,
    required String weaponName,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/Player/$playerId/equipWeapon'),
        headers: headers,
        body: json.encode({'weaponName': weaponName}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error equipping weapon: $e');
      return false;
    }
  }

  // Leaderboard Progress API methods
  static Future<bool> updatePlayerProgress({
    required String playerId,
    int? score,
    int? towerLevel,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {'playerId': playerId};

      if (score != null) requestBody['score'] = score;
      if (towerLevel != null) requestBody['towerLevel'] = towerLevel;

      final response = await http.post(
        Uri.parse('$baseUrl/Leaderboard/UpdateProgress'),
        headers: headers,
        body: json.encode(requestBody),
      );

      print('Update progress response: ${response.statusCode}');
      print('Update progress body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating player progress: $e');
      return false;
    }
  }

  static Future<bool> initializeNewPlayer({required String playerId}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Leaderboard/InitializePlayer'),
        headers: headers,
        body: json.encode({'playerId': playerId}),
      );

      print('Initialize player response: ${response.statusCode}');
      print('Initialize player body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error initializing player: $e');
      return false;
    }
  }
}

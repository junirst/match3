class Player {
  final String playerId;
  final String playerName;
  final String? gender;
  final String? languagePreference;
  final int? towerRecord;
  int? coins; // Made mutable for local updates
  final String? equippedWeapon;
  final DateTime? createdDate;
  final DateTime? lastLoginDate;
  final bool? isActive;

  Player({
    required this.playerId,
    required this.playerName,
    this.gender,
    this.languagePreference,
    this.towerRecord,
    this.coins,
    this.equippedWeapon,
    this.createdDate,
    this.lastLoginDate,
    this.isActive,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      playerId: json['playerId'] ?? '',
      playerName: json['playerName'] ?? '',
      gender: json['gender'],
      languagePreference: json['languagePreference'],
      towerRecord: json['towerRecord'],
      coins: json['coins'],
      equippedWeapon: json['equippedWeapon'],
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : null,
      lastLoginDate: json['lastLoginDate'] != null
          ? DateTime.parse(json['lastLoginDate'])
          : null,
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'gender': gender,
      'languagePreference': languagePreference,
      'towerRecord': towerRecord,
      'coins': coins,
      'equippedWeapon': equippedWeapon,
      'createdDate': createdDate?.toIso8601String(),
      'lastLoginDate': lastLoginDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  Player copyWith({
    String? playerId,
    String? playerName,
    String? gender,
    String? languagePreference,
    int? towerRecord,
    int? coins,
    String? equippedWeapon,
    DateTime? createdDate,
    DateTime? lastLoginDate,
    bool? isActive,
  }) {
    return Player(
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      gender: gender ?? this.gender,
      languagePreference: languagePreference ?? this.languagePreference,
      towerRecord: towerRecord ?? this.towerRecord,
      coins: coins ?? this.coins,
      equippedWeapon: equippedWeapon ?? this.equippedWeapon,
      createdDate: createdDate ?? this.createdDate,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      isActive: isActive ?? this.isActive,
    );
  }
}

class GameSession {
  final int sessionId;
  final String playerId;
  final String gameMode;
  final int? chapterId;
  final int? levelNumber;
  final int? towerFloor;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool? isCompleted;
  final int? finalScore;
  final bool? enemyDefeated;

  GameSession({
    required this.sessionId,
    required this.playerId,
    required this.gameMode,
    this.chapterId,
    this.levelNumber,
    this.towerFloor,
    this.startTime,
    this.endTime,
    this.isCompleted,
    this.finalScore,
    this.enemyDefeated,
  });

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      sessionId: json['sessionId'] ?? 0,
      playerId: json['playerId'] ?? '',
      gameMode: json['gameMode'] ?? '',
      chapterId: json['chapterId'],
      levelNumber: json['levelNumber'],
      towerFloor: json['towerFloor'],
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      isCompleted: json['isCompleted'],
      finalScore: json['finalScore'],
      enemyDefeated: json['enemyDefeated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'playerId': playerId,
      'gameMode': gameMode,
      'chapterId': chapterId,
      'levelNumber': levelNumber,
      'towerFloor': towerFloor,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isCompleted': isCompleted,
      'finalScore': finalScore,
      'enemyDefeated': enemyDefeated,
    };
  }
}

class Chapter {
  final int chapterId;
  final String chapterName;
  final int chapterNumber;
  final String? description;
  final bool isUnlocked;
  final List<Level>? levels;

  Chapter({
    required this.chapterId,
    required this.chapterName,
    required this.chapterNumber,
    this.description,
    required this.isUnlocked,
    this.levels,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['chapterId'] ?? 0,
      chapterName: json['chapterName'] ?? '',
      chapterNumber: json['chapterNumber'] ?? 0,
      description: json['description'],
      isUnlocked: json['isUnlocked'] ?? false,
      levels: json['levels'] != null
          ? (json['levels'] as List)
                .map((level) => Level.fromJson(level))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapterId': chapterId,
      'chapterName': chapterName,
      'chapterNumber': chapterNumber,
      'description': description,
      'isUnlocked': isUnlocked,
      'levels': levels?.map((level) => level.toJson()).toList(),
    };
  }
}

class Level {
  final int levelId;
  final int? chapterId;
  final int levelNumber;
  final String levelName;
  final String? description;
  final int? targetScore;
  final int? movesLimit;
  final bool isUnlocked;

  Level({
    required this.levelId,
    this.chapterId,
    required this.levelNumber,
    required this.levelName,
    this.description,
    this.targetScore,
    this.movesLimit,
    required this.isUnlocked,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      levelId: json['levelId'] ?? 0,
      chapterId: json['chapterId'],
      levelNumber: json['levelNumber'] ?? 0,
      levelName: json['levelName'] ?? '',
      description: json['description'],
      targetScore: json['targetScore'],
      movesLimit: json['movesLimit'],
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'levelId': levelId,
      'chapterId': chapterId,
      'levelNumber': levelNumber,
      'levelName': levelName,
      'description': description,
      'targetScore': targetScore,
      'movesLimit': movesLimit,
      'isUnlocked': isUnlocked,
    };
  }
}

class PlayerProgress {
  final int progressId;
  final String playerId;
  final int? chapterId;
  final int? levelId;
  final bool isCompleted;
  final int? bestScore;
  final DateTime? completedDate;

  PlayerProgress({
    required this.progressId,
    required this.playerId,
    this.chapterId,
    this.levelId,
    required this.isCompleted,
    this.bestScore,
    this.completedDate,
  });

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    return PlayerProgress(
      progressId: json['progressId'] ?? 0,
      playerId: json['playerId'] ?? '',
      chapterId: json['chapterId'],
      levelId: json['levelId'],
      isCompleted: json['isCompleted'] ?? false,
      bestScore: json['bestScore'],
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'progressId': progressId,
      'playerId': playerId,
      'chapterId': chapterId,
      'levelId': levelId,
      'isCompleted': isCompleted,
      'bestScore': bestScore,
      'completedDate': completedDate?.toIso8601String(),
    };
  }
}

class LeaderboardEntry {
  final int leaderboardId;
  final String playerId;
  final String playerName;
  final int score;
  final int rank;
  final int? seasonId;
  final String? seasonName;
  final DateTime? createdDate;

  LeaderboardEntry({
    required this.leaderboardId,
    required this.playerId,
    required this.playerName,
    required this.score,
    required this.rank,
    this.seasonId,
    this.seasonName,
    this.createdDate,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      leaderboardId: json['leaderboardId'] ?? 0,
      playerId: json['playerId'] ?? '',
      playerName: json['playerName'] ?? '',
      score: json['score'] ?? 0,
      rank: json['rank'] ?? 0,
      seasonId: json['seasonId'],
      seasonName: json['seasonName'],
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leaderboardId': leaderboardId,
      'playerId': playerId,
      'playerName': playerName,
      'score': score,
      'rank': rank,
      'seasonId': seasonId,
      'seasonName': seasonName,
      'createdDate': createdDate?.toIso8601String(),
    };
  }
}

class PlayerStats {
  final int totalGamesPlayed;
  final int totalGamesWon;
  final int totalScore;
  final double averageScore;
  final double winRate;
  final int chapterGames;
  final int towerGames;
  final int highestTowerFloor;

  PlayerStats({
    required this.totalGamesPlayed,
    required this.totalGamesWon,
    required this.totalScore,
    required this.averageScore,
    required this.winRate,
    required this.chapterGames,
    required this.towerGames,
    required this.highestTowerFloor,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalGamesWon: json['totalGamesWon'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      averageScore: (json['averageScore'] ?? 0).toDouble(),
      winRate: (json['winRate'] ?? 0).toDouble(),
      chapterGames: json['chapterGames'] ?? 0,
      towerGames: json['towerGames'] ?? 0,
      highestTowerFloor: json['highestTowerFloor'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGamesPlayed': totalGamesPlayed,
      'totalGamesWon': totalGamesWon,
      'totalScore': totalScore,
      'averageScore': averageScore,
      'winRate': winRate,
      'chapterGames': chapterGames,
      'towerGames': towerGames,
      'highestTowerFloor': highestTowerFloor,
    };
  }
}

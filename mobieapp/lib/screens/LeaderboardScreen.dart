import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/game_manager.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLeaderboards();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboards() async {
    final gameManager = Provider.of<GameManager>(context, listen: false);
    await gameManager.loadLeaderboard();

    // Note: Tower leaderboard can be loaded from regular leaderboard data
    // No need for separate state variables
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'LEADERBOARD',
          style: TextStyle(
            fontFamily: 'Bungee',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(offset: Offset(-1, -1), color: Colors.black),
              Shadow(offset: Offset(1, -1), color: Colors.black),
              Shadow(offset: Offset(-1, 1), color: Colors.black),
              Shadow(offset: Offset(1, 1), color: Colors.black),
              Shadow(offset: Offset(0, 0), color: Colors.black, blurRadius: 2),
            ],
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          tabs: const [
            Tab(text: 'GENERAL'),
            Tab(text: 'TOWER'),
          ],
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/backgrounds/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Consumer<GameManager>(
              builder: (context, gameManager, child) {
                return gameManager.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildGeneralLeaderboard(),
                          _buildTowerLeaderboard(),
                        ],
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralLeaderboard() {
    return Consumer<GameManager>(
      builder: (context, gameManager, child) {
        final leaderboard = gameManager.leaderboard;

        if (leaderboard.isEmpty) {
          return const Center(
            child: Text(
              'No leaderboard data available',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadLeaderboards,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final entry = leaderboard[index];
              return _buildLeaderboardCard(
                rank: entry.rank,
                playerName: entry.playerName,
                score: entry.score,
                isCurrentPlayer:
                    gameManager.currentPlayer?.playerId == entry.playerId,
                scoreLabel: 'Score',
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTowerLeaderboard() {
    return Consumer<GameManager>(
      builder: (context, gameManager, child) {
        if (gameManager.leaderboard.isEmpty) {
          return const Center(
            child: Text(
              'No tower leaderboard data available',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadLeaderboards,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: gameManager.leaderboard.length,
            itemBuilder: (context, index) {
              final entry = gameManager.leaderboard[index];

              return _buildLeaderboardCard(
                rank: entry.rank,
                playerName: entry.playerName,
                score: entry.towerLevel,
                isCurrentPlayer:
                    gameManager.currentPlayer?.playerId == entry.playerId,
                scoreLabel: 'Floor',
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardCard({
    required int rank,
    required String playerName,
    required int score,
    required bool isCurrentPlayer,
    String scoreLabel = 'Score',
  }) {
    Color getRankColor() {
      switch (rank) {
        case 1:
          return Colors.amber;
        case 2:
          return Colors.grey[300]!;
        case 3:
          return const Color(0xFFCD7F32);
        default:
          return Colors.blue;
      }
    }

    IconData getRankIcon() {
      switch (rank) {
        case 1:
          return Icons.emoji_events;
        case 2:
          return Icons.workspace_premium;
        case 3:
          return Icons.military_tech;
        default:
          return Icons.person;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCurrentPlayer
              ? [Colors.blue.withOpacity(0.3), Colors.blue.withOpacity(0.1)]
              : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlayer ? Colors.blue : Colors.white.withOpacity(0.2),
          width: isCurrentPlayer ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: getRankColor(),
                shape: BoxShape.circle,
              ),
              child: Icon(
                getRankIcon(),
                color: rank <= 3 ? Colors.white : Colors.white,
                size: rank <= 3 ? 24 : 20,
              ),
            ),
            const SizedBox(width: 16),

            // Rank Number
            SizedBox(
              width: 30,
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: getRankColor(),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Player Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playerName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: isCurrentPlayer
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isCurrentPlayer)
                    const Text(
                      'You',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),

            // Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  score.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  scoreLabel,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to add getTowerLeaderboard to GameManager
extension GameManagerLeaderboard on GameManager {
  Future<List<dynamic>?> getTowerLeaderboard({int limit = 50}) async {
    try {
      // This would use the API service to get tower leaderboard
      // For now, return empty list since we need to implement this in the API service
      return [];
    } catch (e) {
      print('Error getting tower leaderboard: $e');
      return null;
    }
  }
}

import 'package:flutter/material.dart';
import 'dart:math';
import 'audio_manager.dart';

class GameplayScreen extends StatefulWidget {
  final int chapter;
  final int level;

  const GameplayScreen({super.key, required this.chapter, required this.level});

  @override
  _GameplayScreenState createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  bool _isPaused = false;
  List<List<int>> grid = [];
  final Random _random = Random();
  bool _isGridInitialized = false;

  // Image paths for the match-3 game (0=sword, 1=shield, 2=heart, 3=star)
  final List<String> gameImages = [
    'assets/sword.png', // sword
    'assets/shield.png', // shield
    'assets/heart.png', // heart
    'assets/star.png', // star
  ];

  // Fallback icons if images fail to load
  final List<IconData> gameIcons = [
    Icons.sports_martial_arts, // sword
    Icons.shield, // shield
    Icons.favorite, // heart
    Icons.star, // star
  ];

  final List<Color> iconColors = [
    Colors.grey[300]!, // sword - silver
    Colors.blue[300]!, // shield - blue
    Colors.red[300]!, // heart - red
    Colors.yellow[300]!, // star - yellow
  ];

  @override
  void initState() {
    super.initState();
    _initializeGrid();
  }

  void _initializeGrid() {
    // Initialize the grid with random values in one step - changed to 5x5
    grid = List.generate(5, (i) => List.generate(5, (j) => _random.nextInt(4)));

    // Mark grid as initialized
    _isGridInitialized = true;

    print(
      "Grid initialized with ${grid.length} rows and ${grid[0].length} columns",
    );
    print("Sample row: ${grid[0]}");
  }

  void _onTileTap(int row, int col) {
    // Add bounds checking
    if (!_isGridInitialized ||
        row < 0 ||
        row >= grid.length ||
        col < 0 ||
        col >= grid[row].length) {
      print('Invalid tile tap: row=$row, col=$col');
      return;
    }

    AudioManager().playSfx();
    print('Tapped tile at row: $row, col: $col, icon: ${grid[row][col]}');

    setState(() {
      grid[row][col] = (grid[row][col] + 1) % 4;
    });
  }

  void _onPausePressed() {
    AudioManager().playSfx();
    setState(() {
      _isPaused = !_isPaused;
    });

    if (_isPaused) {
      _showPauseDialog();
    }
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;
        final screenWidth = screenSize.width;
        final screenHeight = screenSize.height;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: screenWidth * 0.8,
            height: screenHeight * 0.4,
            decoration: BoxDecoration(
              color: Colors.brown[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.brown[800]!, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'PAUSED',
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Resume button
                    GestureDetector(
                      onTap: () {
                        AudioManager().playSfx();
                        setState(() {
                          _isPaused = false;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: screenWidth * 0.2,
                        height: screenHeight * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.green[800]!,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'RESUME',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Exit button
                    GestureDetector(
                      onTap: () {
                        AudioManager().playSfx();
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Exit to previous screen
                      },
                      child: Container(
                        width: screenWidth * 0.2,
                        height: screenHeight * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.red[800]!, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            'EXIT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameGrid(double screenWidth, double screenHeight) {
    // Add safety check
    if (!_isGridInitialized || grid.isEmpty) {
      return Container(
        width: screenWidth * 0.8,
        height: screenWidth * 0.8,
        decoration: BoxDecoration(
          color: Colors.brown[700]!.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.brown[800]!, width: 3),
        ),
        child: Center(
          child: CircularProgressIndicator(color: Colors.brown[600]),
        ),
      );
    }

    // Use responsive sizing that fits available space
    double gridSize = screenWidth * 0.85;
    double tileSize = gridSize / 5;

    return Container(
      width: gridSize,
      height: gridSize,
      decoration: BoxDecoration(
        color: Colors.brown[700]!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.brown[800]!, width: 3),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: 25,
          itemBuilder: (context, index) {
            int row = index ~/ 5;
            int col = index % 5;

            // Additional safety check
            if (row >= grid.length || col >= grid[row].length) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.brown[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.brown[600]!, width: 2),
                ),
              );
            }

            // Get the image type for this position
            int imageType = grid[row][col];

            return GestureDetector(
              onTap: () => _onTileTap(row, col),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: Colors.brown[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.brown[600]!, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
                child: Container(
                  padding: EdgeInsets.all(4),
                  child: Center(
                    child: Image.asset(
                      gameImages[imageType],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to original icons if images fail to load
                        return Icon(
                          gameIcons[imageType],
                          color: iconColors[imageType],
                          size: tileSize * 0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 1,
                              offset: Offset(1, 1),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Single background image covering entire screen
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Gameplaybg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Fallback background if image fails to load
          Container(
            color: Colors.brown[200],
            child: Image.asset(
              'assets/Gameplaybg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.lightGreen[200]!, Colors.brown[400]!],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Gameplay Background',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main content using Column layout
          SafeArea(
            child: Column(
              children: [
                // Top UI Bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Level indicator on the left
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.brown[600],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Level ${widget.chapter}.${widget.level}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Pause button on the right
                      GestureDetector(
                        onTap: _onPausePressed,
                        child: Container(
                          width: screenWidth * 0.12,
                          height: screenWidth * 0.12,
                          decoration: BoxDecoration(
                            color: Colors.brown[600],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.orange, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/PauseButton.png',
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.pause,
                                color: Colors.white,
                                size: screenWidth * 0.06,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Flexible space for the game grid
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: screenWidth * 0.05,
                        right: screenWidth * 0.05,
                        top: screenWidth * 0.60, // Add more top padding
                        bottom: screenWidth * 0.02, // Reduce bottom padding
                      ),
                      child: _buildGameGrid(screenWidth, screenHeight),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'audio_manager.dart';

class Match3Game extends FlameGame {
  late final int gridSize = 5;
  late final List<List<GameTile?>> grid;
  late final double tileSize;
  late final Vector2 gridOffset;
  final Random _random = Random();
  bool imagesLoaded = false; // Track if images are loaded

  // Selection state for swapping tiles
  GameTile? selectedTile;

  // Callback for when matches occur
  Function(int tileType, int matchCount)? onMatchCallback;

  // Game assets - using your actual asset files
  final Map<int, String> tileSprites = {
    0: 'sword.png',
    1: 'shield.png',
    2: 'heart.png',
    3: 'star.png',
  };

  // Fallback colors (same as your original)
  final List<Color> tileColors = [
    const Color(0xFFE0E0E0), // sword - silver
    const Color(0xFF90CAF9), // shield - blue
    const Color(0xFFEF9A9A), // heart - red
    const Color(0xFFFFF59D), // star - yellow
  ];

  @override
  Future<void> onLoad() async {
    // Set transparent background
    camera.backdrop.removeAll(camera.backdrop.children);

    // Calculate responsive sizing for 5x5 grid
    final screenSize = size;
    tileSize = screenSize.x * 0.12; // Increase tile size back up

    // Center the grid properly within the available space
    final totalGridWidth = gridSize * tileSize + (gridSize - 1) * 4;
    final totalGridHeight = gridSize * tileSize + (gridSize - 1) * 4;

    gridOffset = Vector2(
      (screenSize.x - totalGridWidth) / 2,
      (screenSize.y - totalGridHeight) / 2,
    );

    // Initialize grid
    grid = List.generate(gridSize, (i) => List.generate(gridSize, (j) => null));

    // Load sprites first and wait for completion
    try {
      // Preload all sprite images
      print('Loading sprite images...');
      await images.load('sword.png');
      await images.load('shield.png');
      await images.load('heart.png');
      await images.load('star.png');

      // Verify all images are in cache and set flag
      bool allImagesReady = true;
      for (int i = 0; i < 4; i++) {
        final imageName = tileSprites[i]!;
        if (!images.containsKey(imageName)) {
          allImagesReady = false;
          break;
        }
      }

      if (allImagesReady) {
        imagesLoaded = true;
        print('All sprite images successfully loaded');
      } else {
        print('Not all images loaded, using fallback rendering');
      }
    } catch (e) {
      print('Some images failed to load, will use fallback rendering: $e');
    }

    // Create initial grid only after images are loaded
    await _createInitialGrid();
  }

  @override
  Color backgroundColor() => const Color(0x00000000); // Transparent background

  @override
  void render(Canvas canvas) {
    // Call super to avoid mustCallSuper warning
    super.render(canvas);
  }

  Future<void> _createInitialGrid() async {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        int tileType;

        // Generate a tile type that doesn't create matches with existing tiles
        do {
          tileType = _random.nextInt(4);
        } while (_wouldCreateMatch(row, col, tileType));

        final tile = GameTile(
          tileType: tileType,
          gridRow: row,
          gridCol: col,
          tileSize: tileSize,
          game: this,
        );

        // Position tile on screen
        tile.position = Vector2(
          gridOffset.x + col * (tileSize + 4),
          gridOffset.y + row * (tileSize + 4),
        );

        grid[row][col] = tile;
        add(tile);
      }
    }
  }

  // Check if placing a tile type at the given position would create a match
  bool _wouldCreateMatch(int row, int col, int tileType) {
    // Check horizontal match (3 in a row)
    // Check if this tile would complete a horizontal line of 3
    if (col >= 2) {
      // Check if the two tiles to the left are the same type
      if (grid[row][col - 1]?.tileType == tileType &&
          grid[row][col - 2]?.tileType == tileType) {
        return true;
      }
    }

    if (col >= 1 && col < gridSize - 1) {
      // Check if placing this tile between two same tiles would create a match
      if (grid[row][col - 1]?.tileType == tileType &&
          grid[row][col + 1]?.tileType == tileType) {
        return true;
      }
    }

    // Check vertical match (3 in a column)
    // Check if this tile would complete a vertical line of 3
    if (row >= 2) {
      // Check if the two tiles above are the same type
      if (grid[row - 1][col]?.tileType == tileType &&
          grid[row - 2][col]?.tileType == tileType) {
        return true;
      }
    }

    if (row >= 1 && row < gridSize - 1) {
      // Check if placing this tile between two same tiles would create a match
      if (grid[row - 1][col]?.tileType == tileType &&
          grid[row + 1][col]?.tileType == tileType) {
        return true;
      }
    }

    return false; // No matches would be created
  }

  void onTileTapped(GameTile tile) {
    AudioManager().playSfx();
    print('Tapped tile at ${tile.gridRow}, ${tile.gridCol}');

    if (selectedTile == null) {
      // Select this tile
      selectedTile = tile;
      tile.setSelected(true);
      print('Selected tile at ${tile.gridRow}, ${tile.gridCol}');
    } else if (selectedTile == tile) {
      // Deselect if tapping the same tile
      selectedTile!.setSelected(false);
      selectedTile = null;
      print('Deselected tile');
    } else {
      // Try to swap tiles if they are adjacent
      if (_areAdjacent(selectedTile!, tile)) {
        _swapTiles(selectedTile!, tile);
        selectedTile!.setSelected(false);
        selectedTile = null;
      } else {
        // Select new tile
        selectedTile!.setSelected(false);
        selectedTile = tile;
        tile.setSelected(true);
        print('Selected new tile at ${tile.gridRow}, ${tile.gridCol}');
      }
    }
  }

  bool _areAdjacent(GameTile tile1, GameTile tile2) {
    final rowDiff = (tile1.gridRow - tile2.gridRow).abs();
    final colDiff = (tile1.gridCol - tile2.gridCol).abs();
    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }

  Future<void> _swapTiles(GameTile tile1, GameTile tile2) async {
    print(
      'Swapping tiles at (${tile1.gridRow}, ${tile1.gridCol}) and (${tile2.gridRow}, ${tile2.gridCol})',
    );

    // Swap tile types
    final tempType = tile1.tileType;
    tile1.tileType = tile2.tileType;
    tile2.tileType = tempType;

    // Update visual content
    await tile1._loadTileContent();
    await tile2._loadTileContent();

    // Add swap animation
    tile1.add(
      ScaleEffect.to(
        Vector2.all(1.1),
        EffectController(duration: 0.1, reverseDuration: 0.1),
      ),
    );
    tile2.add(
      ScaleEffect.to(
        Vector2.all(1.1),
        EffectController(duration: 0.1, reverseDuration: 0.1),
      ),
    );

    // Check for matches after swap
    await checkForMatches();
  }

  // Match-3 logic: find and clear matches
  Future<void> checkForMatches() async {
    // Basic match detection - find 3 or more in a row/column
    Set<GameTile> matchedTiles = {};
    Map<int, int> matchCounts = {}; // Track matches by tile type

    // Check horizontal matches
    for (int row = 0; row < gridSize; row++) {
      int count = 1;
      int currentType = grid[row][0]?.tileType ?? -1;

      for (int col = 1; col < gridSize; col++) {
        if (grid[row][col]?.tileType == currentType && currentType != -1) {
          count++;
        } else {
          if (count >= 3) {
            for (int i = col - count; i < col; i++) {
              if (grid[row][i] != null) {
                matchedTiles.add(grid[row][i]!);
                matchCounts[currentType] = (matchCounts[currentType] ?? 0) + 1;
              }
            }
          }
          currentType = grid[row][col]?.tileType ?? -1;
          count = 1;
        }
      }
      if (count >= 3) {
        for (int i = gridSize - count; i < gridSize; i++) {
          if (grid[row][i] != null) {
            matchedTiles.add(grid[row][i]!);
            matchCounts[currentType] = (matchCounts[currentType] ?? 0) + 1;
          }
        }
      }
    }

    // Check vertical matches
    for (int col = 0; col < gridSize; col++) {
      int count = 1;
      int currentType = grid[0][col]?.tileType ?? -1;

      for (int row = 1; row < gridSize; row++) {
        if (grid[row][col]?.tileType == currentType && currentType != -1) {
          count++;
        } else {
          if (count >= 3) {
            for (int i = row - count; i < row; i++) {
              if (grid[i][col] != null) {
                matchedTiles.add(grid[i][col]!);
                matchCounts[currentType] = (matchCounts[currentType] ?? 0) + 1;
              }
            }
          }
          currentType = grid[row][col]?.tileType ?? -1;
          count = 1;
        }
      }
      if (count >= 3) {
        for (int i = gridSize - count; i < gridSize; i++) {
          if (grid[i][col] != null) {
            matchedTiles.add(grid[i][col]!);
            matchCounts[currentType] = (matchCounts[currentType] ?? 0) + 1;
          }
        }
      }
    }

    if (matchedTiles.isNotEmpty) {
      print('Found ${matchedTiles.length} matched tiles!');

      // Call the callback for each tile type that was matched
      if (onMatchCallback != null) {
        for (final entry in matchCounts.entries) {
          final tileType = entry.key;
          final count = entry.value;
          print(
            'Calling match callback for tile type $tileType with count $count',
          );
          onMatchCallback!(tileType, count);
        }
      }

      // Animate matched tiles and remove them
      for (final tile in matchedTiles) {
        tile.add(
          ScaleEffect.to(Vector2.all(0.0), EffectController(duration: 0.3)),
        );
      }

      // Wait for animation to complete
      await Future.delayed(Duration(milliseconds: 350));

      // Replace matched tiles with new random types
      for (final tile in matchedTiles) {
        tile.tileType = _random.nextInt(4);
        await tile._loadTileContent();
        tile.add(
          ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.2)),
        );
      }

      // Check for cascade matches
      await Future.delayed(Duration(milliseconds: 250));
      await checkForMatches();
    }
  }
}

class GameTile extends RectangleComponent with TapCallbacks {
  int tileType;
  int gridRow;
  int gridCol;
  final double tileSize;
  final Match3Game game;

  late final RectangleComponent background;
  late final RectangleComponent selectionBorder;
  SpriteComponent? spriteComponent;
  TextComponent? fallbackText;

  GameTile({
    required this.tileType,
    required this.gridRow,
    required this.gridCol,
    required this.tileSize,
    required this.game,
  }) : super(size: Vector2(tileSize, tileSize));

  @override
  Future<void> onLoad() async {
    // Don't add any background at all - completely transparent tile

    // Keep only the border for tile definition
    final border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color =
            const Color(0xFF8D6E63) // Brown[600] equivalent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Selection border (initially invisible)
    selectionBorder = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    selectionBorder.opacity = 0;

    // Add border and selection border
    add(border);
    add(selectionBorder);

    // Load content - this will now properly check if images are ready
    await _loadTileContent();
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Pass the tap to the game's tile handling logic
    game.onTileTapped(this);
  }

  Future<void> _loadTileContent() async {
    // Remove existing content
    if (spriteComponent != null) {
      spriteComponent!.removeFromParent();
      spriteComponent = null;
    }
    if (fallbackText != null) {
      fallbackText!.removeFromParent();
      fallbackText = null;
    }

    // Remove any existing colored background from fallback
    final componentsToRemove = children
        .where(
          (component) =>
              component is RectangleComponent &&
              component != selectionBorder &&
              component.paint.style == PaintingStyle.fill,
        )
        .toList();

    for (final component in componentsToRemove) {
      component.removeFromParent();
    }

    // Check if images are loaded and try to use sprites
    if (game.imagesLoaded) {
      try {
        final imageName = game.tileSprites[tileType]!;

        if (game.images.containsKey(imageName)) {
          final sprite = Sprite(game.images.fromCache(imageName));
          spriteComponent = SpriteComponent(
            sprite: sprite,
            size: Vector2(tileSize * 0.8, tileSize * 0.8),
            position: Vector2(tileSize * 0.1, tileSize * 0.1),
          );
          add(spriteComponent!);
          return; // Successfully loaded sprite, no need for fallback
        }
      } catch (e) {
        print('Failed to load sprite for tile $tileType: $e');
      }
    }

    // Use fallback content if images aren't loaded or failed to load
    _createFallbackContent();
  }

  void _createFallbackContent() {
    // Colored circles with text as fallback if images don't load
    final labels = ['SW', 'SH', 'HT', 'ST']; // Sword, Shield, Heart, Star
    final colors = [
      const Color(0xFFE0E0E0), // sword - silver
      const Color(0xFF90CAF9), // shield - blue
      const Color(0xFFEF9A9A), // heart - red
      const Color(0xFFFFF59D), // star - yellow
    ];

    // Create a colored background circle
    final coloredBackground = RectangleComponent(
      size: Vector2(tileSize * 0.8, tileSize * 0.8),
      position: Vector2(tileSize * 0.1, tileSize * 0.1),
      paint: Paint()
        ..color = colors[tileType]
        ..style = PaintingStyle.fill,
    );
    add(coloredBackground);

    fallbackText = TextComponent(
      text: labels[tileType],
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: tileSize * 0.3,
          color: Colors.black,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.transparent,
        ),
      ),
      position: Vector2(tileSize * 0.3, tileSize * 0.35),
    );
    add(fallbackText!);
  }

  void setSelected(bool selected) {
    selectionBorder.opacity = selected ? 1.0 : 0.0;
  }

  void changeTileType() {
    tileType = (tileType + 1) % 4;
    _loadTileContent();

    // Add visual feedback with scale effect
    add(
      ScaleEffect.to(
        Vector2.all(1.2),
        EffectController(duration: 0.1, reverseDuration: 0.1),
      ),
    );
  }
}
